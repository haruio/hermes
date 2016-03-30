defmodule HQueue.QueueRepository do
  use ExActor.GenServer, export: __MODULE__

  alias HQueue.Queue

  @init_state %{
    name_table: nil,
    ref_map: %{}
  }

  require Logger

  defstart start_link do
    Logger.info "[#{__MODULE__}] QueueRepository start"
    initial_state(%{@init_state | name_table: :ets.new(:queue_repository, [:set, :private, :named_table])})
  end

  defcall declare(name), state: state do
    case :ets.lookup(state.name_table, name) do
      [{_name, pid, _ref}] ->
        reply {:ok, pid}
      [] ->
        {:ok, pid} = Queue.new(name)
        ref = Process.monitor(pid)
        :ets.insert(state.name_table, {name, pid, ref})
        new_ref_map = Map.put(state.ref_map, ref, {name, pid})
        set_and_reply(%{state | ref_map: new_ref_map}, {:ok, pid})
    end
  end

  def handle_info({:DOWN, ref, :process, pid, _reason}, %{name_table: name_table, ref_map: ref_map}=state) do
    # get by  ref
    case Map.get(ref_map, ref) do
      {name, _pid} ->
        new_map = Map.delete(ref_map, ref)
        :ets.delete(name_table, name)
        Process.demonitor(ref)
        {:noreply, %{state | ref_map: new_map}}
      nil ->
        {:noreply, state}
    end
  end

  def handle_info(msg, state) do
    {:noreply, state}
  end
end
