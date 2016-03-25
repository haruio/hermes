defmodule Producer.Router.LocalPushRouter do
  @behavior Producer.Router.RouterBehavior

  require Logger

  @queue_name "local.push.publish.data"

  def new do
    Logger.info "[#{__MODULE__}] new"

    {:ok, exchange} = HQueue.Exchange.new
    {:ok, queue} = HQueue.Queue.declare(@queue_name)
    HQueue.Exchange.bind(exchange, queue)

    {:ok, exchange}
  end

  def publish_immediate(exchange, message) do
    HQueue.Exchange.publish(exchange, message)
  end

  def publish_reserve({:reserve, %{push_id: push_id, push_tokens: push_tokens}}) do
    HScheduler.Store.PushTokenStore.add(push_id, push_tokens)
  end
end
