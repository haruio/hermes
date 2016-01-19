defmodule Producer.PushProducer do
  use GenServer

  defmodule State do
    defstruct [:exchange, :router]
  end

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    router = Application.get_env(:hermes_api, __MODULE__)
    {:ok, exchange} = router[:adapter].new

    {:ok, %{exchange: exchange, router: router[:adapter]}}
  end

  def publish_immediate(message) do
    :poolboy.transaction(__MODULE__, fn(worker) -> GenServer.cast(worker, {:publish_immediate, message}) end)
  end

  def publish_reserve(message) do
    :poolboy.transaction(__MODULE__, fn(worker) -> GenServer.cast(worker, {:publish_reserve, message}) end)
  end

  def handle_cast({:publish_immediate, message}, state) do
    state.router.publish_immediate(state.exchange, message)
    {:noreply, state}
  end

  def handle_cast({:publish_reserve, message}, state) do
    state.router.publish_immediate(state.exchange, message)
    {:noreply, state}
  end
end
