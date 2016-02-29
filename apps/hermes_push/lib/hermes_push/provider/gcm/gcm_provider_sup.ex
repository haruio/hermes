defmodule HPush.Provider.GCMProviderSup do
  use Supervisor

  alias HPush.Provider.GCMProvider

  def start_link(args \\ []), do: Supervisor.start_link(__MODULE__, args, [name: __MODULE__])

  def init(args) do
    gcm_provider_opts = Application.get_env(:hermes_push, GCMProvider)
    children =[
      :poolboy.child_spec(GCMProvider, pool_config, [[gcm_provider_opts]])
    ]

    supervise(children, strategy: :one_for_one)
  end

  defp pool_config do
    [
      {:name, {:local, GCMProvider.pool_name}},
      {:worker_module, GCMProvider},
      {:size, 10},
      {:max_overflow, 1000},
      {:strategy, :fifo}
    ]
  end
end
