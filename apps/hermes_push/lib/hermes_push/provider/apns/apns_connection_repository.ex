defmodule HPush.Provider.APNSConnectionRepository do
  use ExActor.GenServer, export: __MODULE__

  defstart start_link(args \\ %{}), do: initial_state(args)

  defcall get_repository(message), state: state do
    service_id = Map.get(message, :service_id)
    env = Map.get(message, :apns_env)

    case Map.get(state, service_id, nil) do
      nil ->
        p = pool_name(service_id, env)
        config = pool_config(Map.take(message, [:apns_cert, :apns_key, :apns_env]))
        new_state = Map.put(state, p, p)
        APNS.connect_pool(p, config)
        set_and_reply(new_state, {:ok, p})
      p ->
        reply({:ok, p})
    end
  end

  def pool_name(service_id, env), do: Atom.to_string(env) <> "::" <> service_id |> APNS.pool_name
  def pool_config(message) do
    config = %{}
    config = case :public_key.pem_decode(Map.get(message, :apns_cert)) do
             [{:Certificate, certDer, _}] -> config |> Dict.put(:cert, certDer)
             _ -> config
           end

    config = case :public_key.pem_decode(Map.get(message, :apns_key)) do
            [{:RSAPrivateKey, keyDer, _}] -> config |> Dict.put(:key, { :RSAPrivateKey, keyDer})
            _ -> config
          end

    [
      env: Map.get(message, :apns_env, :dev),
      pool_size: 5,
      pool_max_overflow: 5,
      cert: config.cert,
      key: config.key
    ]
  end

end
