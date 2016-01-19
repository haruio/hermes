defmodule Producer.Router.LocalPushRouter do
  @behavior Producer.Router.RouterBehavior

  @queue_name "local.push.publish.data"

  def new do
    {:ok, exchange} = HQueue.Exchange.new
    {:ok, queue} = HQueue.Queue.declare(@queue_name)
    HQueue.Exchange.bind(exchange, queue)

    {:ok, exchange}
  end

  def publish_immediate(exchange, message) do
    HQueue.Exchange.publish(exchange, message)
  end

  def publish_reserve(exchange, message) do
    IO.puts "local route reserve"
  end
end
