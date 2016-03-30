defmodule Producer.PushProducer do
  use GenServer

  defmodule ProducerState do
    defstruct queue: nil, router: nil, buffer: :queue.new
  end

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    router = Application.get_env(:hermes_api, __MODULE__)
    {:ok, queue} = router[:adapter].new
    Process.monitor(queue)

    {:ok, %ProducerState{queue: queue, router: router[:adapter]}}
  end

  def publish_immediate(message) do
    :poolboy.transaction(__MODULE__, fn(worker) -> GenServer.cast(worker, {:publish_immediate, message}) end)
  end

  def publish_reserve(message) do
    :poolboy.transaction(__MODULE__, fn(worker) -> GenServer.cast(worker, {:publish_reserve, message}) end)
  end

  ## Callback API
  def handle_cast({:publish_immediate, message}, state) do
    state.router.publish_immediate(state.exchange, message)
    {:noreply, state}
  end

  def handle_cast({:publish_reserve, message}, state) do
    state.router.publish_reserve(message)
    {:noreply, state}
  end
end
