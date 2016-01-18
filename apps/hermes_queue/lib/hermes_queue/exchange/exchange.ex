defmodule HQueue.Exchange do
  use ExActor.GenServer

  alias HQueue.ExchangeSup


  @default_topic "default"

  defstart start_link(state),do: initial_state(state)
  defstart start_link, do: initial_state(%{})

  defcall bind(queue, topic \\ @default_topic), state: state do
    case Map.get(state, topic) do
      nil ->
        topics = MapSet.new |> MapSet.put(queue)
        Map.put(state, topic, topics)
        |> set_and_reply(:ok)
      topics ->
        topics = MapSet.put(topics, queue)
        Map.put(state, topic, topics)
        |> set_and_reply(:ok)
    end
  end

  defcast publish(message, topic \\ @default_topic), state: state do
    case Map.get(state, topic) do
      nil -> noreply
      topics ->
        MapSet.to_list(topics)
        |> Enum.each &(HQueue.Queue.publish(&1, message))
        noreply
    end
  end

  def new(args \\ []) do
    Supervisor.start_child(ExchangeSup, args)
  end

end
