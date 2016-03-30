defmodule HScheduler.Producer.PushProducer do
  use GenServer

  @queue_name "local.push.publish.data"

  alias HScheduler.Model.Push
  alias HScheduler.Model.Push.Query, as: PushQuery
  alias HScheduler.Model.Service.Query, as: ServiceQuery
  alias HScheduler.Model.PushOption.Query, as: PushOptionQuery
  alias HScheduler.Store.PushTokenStore

  def pool_name, do: __MODULE__

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    {:ok, queue} = HQueue.Queue.declare(@queue_name)

    Process.monitor(queue)

    state = %{
      queue: queue
    }

    {:ok, state}
  end

  def publish(push) do
    ## Publish To Queue
    :poolboy.transaction(pool_name, fn(producer) ->
      GenServer.call(producer, {:publish, push})
    end)
  end

  def handle_call({:publish, push}, _from, state) do
    ## select service
    service = ServiceQuery.select_one_by_service_id(push.service_id)

    ## publish loop
    publish_loop(push, service, state)

    {:reply, state, state}
  end

  def publish_loop(push, service, state) do
    case PushTokenStore.select_all(push.push_id) do
      nil -> :ok
      tokens ->
        ## update push status
        Push.changeset(push, %{push_status: "PUING", publish_start_dt: Ecto.DateTime.utc})
        |> PushQuery.update

        options = PushOptionQuery.select(push_id: push.push_id)

        ## publish tokens
        tokens
        |> Enum.map(&(publish_task(push, service, options, state, &1)))
        |> Enum.map(&Task.await/1)
        |> done(push.push_id)
    end
  end

  def publish_task(push, service, options, state, {push_id, tokens}) do
    Task.async(fn ->
      ## publish message
      message = build_message(push, service, options, tokens)
      HQueue.Queue.publish(state.queue, message)
    end)
  end

  def done(_result, push_id) do
    PushTokenStore.delete(push_id)
  end

  defp build_message(push_model, service_model, option_models, tokens) do
    options = option_models |> build_options

    push_model
    |> Map.take([:push_id, :service_id, :title, :body, :publish_time, :extra])
    |> Map.put(:push_tokens, tokens)
    |> Map.put(:options, options)
    |> Map.put(:gcm_api_key, Map.get(service_model,:gcm_api_key))
    |> Map.merge(get_apns_key(service_model, options[:apns]["env"]))
  end

  def get_apns_key(service_model, nil), do: get_apns_key(service_model, "dev")
  def get_apns_key(service_model, "dev") do
    %{
      apns_key: Map.get(service_model, :apns_dev_key),
      apns_cert: Map.get(service_model, :apns_dev_cert)
    }
  end
  def get_apns_key(service_model, "prod") do
    %{
      apns_key: Map.get(service_model, :apns_key),
      apns_cert: Map.get(service_model, :apns_cert)
    }
  end

  defp build_options([]), do: %{}
  defp build_options(options) do
    options
    |> Enum.reduce(%{apns: nil, gcm: nil}, fn(option, acc) ->
      case option.push_type do
        "APNS" -> %{acc | apns: option.option |> Poison.decode! }
        "GCM" -> %{acc | gcm: option.optoin |> Poison.decode! }
        _ -> acc
      end
    end)
  end
end
