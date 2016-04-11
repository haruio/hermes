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
    if Process.alive?(state.queue) do
      state.router.publish_immediate(state.queue, message)
      if :queue.is_empty(state.buffer) == false do
        :queue.to_list(state.buffer)
        |> Enum.each(&(state.router.publish_immediate(state.queue, &1)))

        {:noreply, %ProducerState{state | buffer: :queue.new}}
      else
        {:noreply, state}
      end
    else
      {:noreply, %ProducerState{state | buffer: :queue.in(state.buffer, message)}}
    end
  end

  def handle_cast({:publish_reserve, message}, state) do
    state.router.publish_reserve(message)
    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
    if state.queue == pid do
      Process.demonitor(ref)
      {:ok, queue} = state.router[:adapter].new
      Process.monitor(queue)
      {:noreply, %ProducerState{state | queue: queue}}
    else
      {:noreply, state}
    end
  end
end
