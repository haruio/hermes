defmodule HPush.Provider.APNSConnectionRepository do
  use ExActor.GenServer, export: __MODULE__

  require Logger

  defstart start_link(args \\ %{}), do: initial_state(args)

  @default_apns_env :dev

  defcall get_repository(message), state: state do
    Logger.debug "[#{__MODULE__}] handle_call get_repository"
    env = case message[:options][:apns]["env"] do
            "prod" -> :prod
            "dev" -> :dev
            _ -> @default_apns_env
          end
    p_name = pool_name(message[:service_id], env)

    case Map.get(state, p_name, nil) do
      nil ->
        pool  = message
        |> Map.take([:apns_cert, :apns_key, :service_id, :push_id])
        |> Map.put(:env, env)
        |> create_new_pool

        new_state = Map.put(state, p_name, pool)
        set_and_reply(new_state, {:ok, p_name})
     pool ->
        reply({:ok, pool[:name]})
    end
  end

  defp create_new_pool(%{service_id: service_id, apns_cert: apns_cert, apns_key: apns_key, env: env, push_id: push_id} = config) do
    pool = %{
      name: pool_name(service_id, env),
      config: pool_config(config),
      time: Calendar.DateTime.now_utc
    }
    APNS.connect_pool(pool[:name], pool[:config])
    Logger.debug "[#{__MODULE__}] create new pool: #{inspect Map.take(pool, [:name, :time])}"

    pool
  end


  def pool_name(service_id, env), do: Atom.to_string(env) <> "::" <> service_id
  def pool_config(config) do
    [
      env: Map.get(config, :env),
      pool_size: 5,
      pool_max_overflow: 20,
      cert: Map.get(config, :apns_cert),
      key: Map.get(config, :apns_key),
      strategy: :fifo
    ]
  end
end
