defmodule HQueue.QueueTimer do
  use GenServer

  @default_interval 10000
  defmodule State do
    defstruct interval: @default_interval, callback: nil
  end

  ## Public API
  def start_link(options) do
    GenServer.start_link(__MODULE__, options)
  end

  def init(options) do
    state = %State{
      interval: Keyword.get(options, :interval, @default_interval),
      callback: Keyword.get(options, :callback)
    }

    Process.send_after(self, :tick, state.interval)
    {:ok, state}
  end


  ## Callback API
  def handle_info(:tick, %State{interval: interval, callback: callback}=state) do
    callback.()
    Process.send_after(self, :tick, interval)
    {:noreply, state}
  end
end
