defmodule HQueue.Queue do
  use ExActor.GenServer

  alias HQueue.QueueSup
  alias HQueue.QueueRepository
  alias HQueue.QueueState

  defstart start_link, do: initial_state(:queue.new)

  defcast publish(message), state: state do
    :queue.in(message, state)
    |> new_state
  end

  defcall consume, state: state do
    case :queue.out(state) do
      {{:value, item}, queue} -> set_and_reply(queue, {:ok, item})
      {:empty, _} -> reply :empty
    end
  end
  defcast consume(form), state: state do
    case :queue.out(state) do
      {{:value, item}, queue} ->
        send(form, {:ok, item})
        new_state(queue)
      {:empty, _} ->
        send(form, :empty)
        noreply
    end
  end

  def declare(name), do: QueueRepository.declare(name)
  def new(args \\ []) , do: Supervisor.start_child(QueueSup, args)
end

defmodule HQueue.QueueState do
  defstruct name: nil, queue: nil
end
