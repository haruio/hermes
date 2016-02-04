defmodule HScheduler.Producer.PushProducer do
  use GenServer

  @queue_name "local.push.publish.data"

  alias HScheduler.Model.Push
  alias HScheduler.Model.Push.Query, as: PushQuery
  alias HScheduler.Model.Service.Query, as: ServiceQuery
  alias HScheduler.Store.PushTokenStore

  def pool_name, do: __MODULE__

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    {:ok, exchange} = HQueue.Exchange.new
    {:ok, queue} = HQueue.Queue.declare(@queue_name)
    HQueue.Exchange.bind(exchange, queue)

    state = %{
      exchange: exchange
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

        ## publish tokens
        tokens
        |> Enum.map(&(publish_task(push, service, state, &1)))
        |> Enum.map(&Task.await/1)
        |> done(push.push_id)
    end
  end

  def publish_task(push, service, state, {_push_id, tokens}) do
    Task.async(fn ->
      ## publish message
      message = build_message(push, service, tokens)
      HQueue.Exchange.publish(state.exchange, message)
    end)
  end

  def done(_result, push_id) do
    PushTokenStore.delete(push_id)
  end


  def build_message(push_model, service_model, tokens) do
    push_model
    |> Map.take([:push_id, :service_id, :title, :body, :publish_time, :extra])
    |> Map.put(:push_tokens, tokens)
    |> Map.put(:apns_env, :dev) ## TODO apns_options
    |> Map.merge(Map.take(service_model, [:gcm_api_key, :apns_key, :apns_cert]))
  end
end
