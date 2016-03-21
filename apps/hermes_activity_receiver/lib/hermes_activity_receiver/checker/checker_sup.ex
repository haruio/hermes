defmodule HActivity.CheckerSup do
  use Supervisor

  def start_link(args \\ []), do: Supervisor.start_link(__MODULE__, args, [name: __MODULE__])

  def init(args) do
    children = [
      worker(HActivity.StatsChecker.Timer, []),
      worker(HActivity.StatsChecker.Buffer, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
