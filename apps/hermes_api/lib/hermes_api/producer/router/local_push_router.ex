defmodule Producer.Router.LocalPushRouter do
  @behavior Producer.Router.RouterBehavior

  require Logger

  @queue_name "local.push.publish.data"

  def new do
    Logger.info "[#{__MODULE__}] new"
    {:ok, queue} = HQueue.Queue.declare(@queue_name)
    {:ok, queue}
  end

  def publish_immediate(queue, message) do
    HQueue.Queue.publish(queue, message)
  end

  def publish_reserve({:reserve, %{push_id: push_id, push_tokens: push_tokens}}) do
    HScheduler.Store.PushTokenStore.add(push_id, push_tokens)
  end
end
