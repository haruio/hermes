defmodule HQueue.QueueRepository do
  use ExActor.GenServer, export: __MODULE__

  alias HQueue.Queue

  require Logger

  defstart start_link do
    Logger.info "[#{__MODULE__}] QueueRepository start"
    initial_state(%{})
  end

  defstart start_link(state) do
    Logger.info "[#{__MODULE__}] QueueRepository start by #{inspect state}"
    initial_state(state)
  end


  defcall get(name), state: state do
    reply Map.fetch(state, name)
  end

  defcall declare(name), state: state do
    case Map.fetch(state, name) do
      {:ok, queue} -> reply {:ok, queue}
      :error ->
        {:ok, queue} = Queue.new(name)
        new_state = Map.put(state, name, queue)
        set_and_reply(new_state, {:ok, queue})
    end
  end

  defcast set(name, queue_pid), state: state do
    Map.put(state, name, queue_pid)
    |> new_state
  end

  defcall status, state: state do
    reply state
  end
end
