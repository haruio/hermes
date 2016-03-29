defmodule HPush.FeedbackSup do
  use Supervisor

  def start_link(args \\ []) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      :poolboy.child_spec(HPush.Feedback, pool_config, []),
      worker(HPush.FeedbackMan, [])
    ]

    supervise(children, strategy: :one_for_one)
  end

  defp pool_config do
    [
      {:name, {:local, HPush.Feedback}},
      {:worker_module, HPush.Feedback},
      {:size, 50},
      {:max_overflow, 1000},
      {:strategy, :fifo}
    ]
  end
end
