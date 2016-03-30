defmodule HQueue.QueueStateRepository do
  use GenServer

  def start_link(args \\ []), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  def init(args) do
    {:ok, %{state_table: :ets.new(:queue_state_table, [:set, :named_table, :private])}}
  end


  def insert(q_state) do
    GenServer.cast(__MODULE__, {:insert, q_state})
  end

  def select(name) do
    GenServer.call(__MODULE__, {:select, name})
  end


  def handle_cast({:insert, q_state}, state) do
    IO.puts "insert #{inspect state}"
    :ets.insert(state.state_table, {q_state.name, q_state})
    {:noreply, state}
  end

  def handle_call({:select, name}, _from, state) do
    case :ets.lookup(state.state_table, name) do
      [{_name, q_state}] ->
        :ets.delete_object(state.state_table, name)
        {:reply, {:ok, q_state}, state}
      [] ->
        {:reply, :error}
    end
  end
end
