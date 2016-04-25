defmodule HPush.Provider.APNSConnectionRepository do
  use GenServer

  @default_apns_env :dev

  defmodule State do
    defstruct conn_map: %{}
  end

  def start_link(args \\ %{}) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_args) do
    {:ok, %State{}}
  end

  ## Public API
  def get_repository(message) do
    GenServer.call(__MODULE__, {:get_repository, message})
  end


  ## Callback API
  def handle_call({:get_repository, message}, _from, %State{conn_map: conn_map}=state) do
    env = case message[:options][:apns]["env"] do
            "prod" -> :prod
            "dev" -> :dev
            _ -> @default_apns_env
          end
    p_name = pool_name(message[:service_id], env)

    case Map.get(conn_map, p_name, nil) do
      nil ->
        pool  = message
        |> Map.take([:apns_cert, :apns_key, :service_id, :push_id])
        |> Map.put(:env, env)
        |> create_new_pool

        {:reply, {:ok, p_name}, %State{state | conn_map: Map.put(conn_map, p_name, pool)}}
      pool ->
        {:reply, {:ok, pool[:name]}, state}
    end

  end

  ## Private API
  defp create_new_pool(%{service_id: service_id, apns_cert: apns_cert, apns_key: apns_key, env: env, push_id: push_id} = config) do
    p_name = pool_name(service_id, env)
    {:ok, queue} = HQueue.Queue.declare(p_name)
    {:ok, pool_man} = HPush.Provider.APNSConnectionPoolMan.start_link(p_name)
    pool = %{
      name: p_name,
      config: pool_config(config),
      queue: queue,
      time: Calendar.DateTime.now_utc
    }
    APNS.connect_pool(pool[:name], pool[:config])

    pool
  end

  defp pool_name(service_id, env), do: Atom.to_string(env) <> "::" <> service_id
  defp pool_config(config) do
    [
      env: Map.get(config, :env),
      pool_size: 50,
      pool_max_overflow: 0,
      cert: Map.get(config, :apns_cert),
      key: Map.get(config, :apns_key),
      strategy: :fifo,
      support_old_ios: false,
      timeout: 120 # sec
    ]
  end
end
