defmodule HActivity.StatsChecker.Timer do
  use ExActor.GenServer

  @tick_interval 5000

  defstart start_link(args \\ []) do
    tick
    initial_state(args)
  end

  defhandleinfo :tick do
    if Process.whereis(HActivity.StatsChecker.Buffer) |> is_pid do
      HActivity.StatsChecker.Buffer.flush
    end

    tick
    noreply
  end

  def tick, do: Process.send_after(self, :tick, @tick_interval)
end
