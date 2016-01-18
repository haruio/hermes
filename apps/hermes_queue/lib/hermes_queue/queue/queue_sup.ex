defmodule HQueue.QueueSup do
  use Supervisor

  alias HQueue.Queue

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(Queue, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
