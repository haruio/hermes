defmodule Splunk.ConnectionPool do
  use Supervisor

  def start_link(args \\ []), do: Supervisor.start_link(__MODULE__, args)

  def init(args) do
    children = [
      :poolboy.child_spec(Splunk, pool_config, args)
    ]

    supervise(children, strategy: :one_for_one)
  end

  defp pool_config do
    [
      {:name, {:local, Splunk.ConnectionPool}},
      {:worker_module, Splunk},
      {:size, 10},
      {:max_overflow, 1000},
      {:strategy, :fifo}
    ]
  end

  def send(data) do
    :poolboy.transaction(Splunk.ConnectionPool, fn(splunk) ->
      Splunk.send(splunk, data)
    end)
  end
end
