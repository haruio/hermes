defmodule HQueue.QueueRootSup do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: HQueue.QueueRootSup)
  end

  def init(args) do
    children = [
      worker(HQueue.QueueRepository, []),
      worker(HQueue.QueueStateRepository, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
