defmodule HPush.DispatcherSup do
  use Supervisor

  alias HPush.Dispatcher

  def start_link(args \\ []), do: Supervisor.start_link(__MODULE__, args, [name: __MODULE__])
  def init(args) do
    children = [
      :poolboy.child_spec(Dispatcher, pool_config, [])
    ]


    supervise(children, strategy: :one_for_one)
  end

  defp pool_config do
    [
      {:name, {:local, Dispatcher.pool_name}},
      {:worker_module, Dispatcher},
      {:size, 10},
      {:max_overflow, 1000},
      {:strategy, :fifo}
    ]
  end
end
