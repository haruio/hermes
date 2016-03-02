defmodule HPush.CheckerSup do
  use Supervisor

  def start_link(args \\ []), do: Supervisor.start_link(__MODULE__, args, [name: CheckerSup])

  def init(args) do
    children = [
      worker(HPush.StatsChecker.Timer, []),
      worker(HPush.StatsChecker.Buffer, []),

      worker(HPush.StatusCheker, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
