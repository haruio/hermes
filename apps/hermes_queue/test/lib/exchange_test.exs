defmodule ExchangeTest do
  use ExUnit.Case, async: false

  alias HQueue.Queue
  alias HQueue.Exchange


  test "bind default topic" do
    {:ok, exchange} = Exchange.new
    {:ok, queue} = Queue.declare("test.queue.data")

    assert :ok == Exchange.bind(exchange, queue)
  end

  test "bind custom topic" do
    {:ok, exchange} = Exchange.new
    {:ok, queue1} = Queue.declare("test.queue.data1")
    {:ok, queue2} = Queue.declare("test.queue.data2")
    {:ok, queue3} = Queue.declare("test.queue.data3")

    assert :ok == Exchange.bind(exchange, queue1, "test.queue.topic1")
    assert :ok == Exchange.bind(exchange, queue2, "test.queue.topic2")
    assert :ok == Exchange.bind(exchange, queue3, "test.queue.topic2")
  end

  test "publish message to  exchange " do
    {:ok, exchange} = Exchange.new
    {:ok, queue2} = Queue.declare("test.queue.data2")
    {:ok, queue3} = Queue.declare("test.queue.data3")
    {:ok, queue4} = Queue.declare("test.queue.data4")

    Exchange.bind(exchange, queue2, "test.queue.topic2")
    Exchange.bind(exchange, queue3, "test.queue.topic2")
    Exchange.bind(exchange, queue4, "test.queue.topic2")


    Exchange.publish(exchange, "test message", "test.queue.topic2")


    {_id, message} = Queue.consume(queue2)
    assert message == "test message"

    {_id, message} = Queue.consume(queue3)
    assert message == "test message"

    {_id, message} = Queue.consume(queue4)
    assert message == "test message"
  end

  test "publish and ack" do
    {:ok, ex} = Exchange.new
    {:ok, queue} = Queue.declare("test.queue.data")
    Exchange.bind(ex, queue, "test.queue.topic")

    Exchange.publish(ex, "test message", "test.queue.topic")
    IO.inspect Queue.status(queue)
    {msg_id, msg} = Queue.consume(queue)
    IO.inspect msg
    IO.inspect Queue.status(queue)
    Queue.ack(queue, msg_id)
    IO.inspect Queue.status(queue)
  end
end
