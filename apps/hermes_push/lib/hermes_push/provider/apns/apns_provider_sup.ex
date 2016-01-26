defmodule HPush.Provider.APNSProviderSup do
  use Supervisor

  alias HPush.Provider.APNSProvider
  alias HPush.Provider.APNSConnectionRepository, as: ConnRepo

  def start_link(args \\ []), do: Supervisor.start_link(__MODULE__, args, [name: __MODULE__])
  def init(args) do
    apns_provider_opts = Application.get_env(:hermes_push, APNSProvider)
    children = [
      :poolboy.child_spec(APNSProvider, pool_config, [[apns_provider_opts]]),
      worker(ConnRepo, [])
    ]

    supervise(children, strategy: :one_for_one)
  end

  defp pool_config do
    [
      {:name, {:local, APNSProvider.pool_name}},
      {:worker_module, APNSProvider},
      {:size, 10},
      {:max_overflow, 1000},
      {:strategy, :fifo}
    ]
  end
end
