defmodule HScheduler.Job.JobSup do
  use Supervisor

  def start_link, do: Supervisor.start_link(__MODULE__, :ok, [name: __MODULE__])

  def init(:ok) do
    children = [
      worker(HScheduler.Job.CancelReservedPush, []),
      worker(HScheduler.Job.PublishReservedPush, [])
    ]

    supervise(children, strategy: :one_for_one)
  end

end
