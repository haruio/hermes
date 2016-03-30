defmodule HQueue.Queue do
  use GenServer

  alias HQueue.QueueSup
  alias HQueue.QueueRepository

  require Logger

  defmodule  QueueState do
    defstruct name: nil,
    queue: :queue.new,
    unacked: %{},
    consumers: :queue.new
  end

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def publish(pid, message) do
    GenServer.cast(pid, {:publish, message})
  end

  def consume(pid) do
    GenServer.call(pid, :consume, :infinity)
  end

  def status(pid) do
    GenServer.call(pid, :status)
  end

  def status_detail(pid) do
    GenServer.call(pid, :status_detail)
  end

  def ack(pid, message_id) do
    GenServer.cast(pid, {:ack, message_id})
  end

  ## Callback API
  def init(state) do
    Logger.info "[#{__MODULE__}] start Queue"

    {:ok, state}
  end

  def handle_cast({:publish, message}, state) do
    Logger.debug "[#{inspect __MODULE__}] publish"

    message = build_message(message)
    {:noreply, queueing_message(message, state)}
  end

  def handle_call(:consume, from, state) do
    Logger.debug "[#{inspect __MODULE__}] consume"

    case :queue.out(state.queue) do
      {{:value, message}, q} ->
        {:reply, message, %{state | queue: q, unacked: add_unacked(state.unacked, from, message)}}
      {:empty, _q} ->
        {:noreply, queueing_consumer(from, state)}
    end
  end

  def handle_call(:status, _from, state) do
    status = %{
      queue: :queue.len(state.queue),
      unacked: Map.keys(state.unacked) |> length,
      consumers: :queue.len(state.consumers)
    }

    {:reply, status, state}
  end

  def handle_call(:status_detail, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:ack, message_id}, %QueueState{ unacked: unacked } = state) do
    Logger.debug "[#{__MODULE__}] ack"

    {:noreply,  %{state | unacked: Map.delete(state.unacked, message_id)}}
  end

  def handle_info(msg, state) do
    {:noreply, state}
  end

  def terminate(_reason, state) do
    HQueue.QueueStateRepository.insert(state)
  end

  ## Private API
  defp queueing_message(message, state) do
    Logger.debug "[#{__MODULE__}] queuing_message"

    case get_alive_consumer(state.consumers) do
      {{:value, consumer}, consumers} ->
        GenServer.reply(consumer, message)
        %{state | consumers: consumers, unacked: add_unacked(state.unacked, consumer, message)}
      {:empty, _q} ->
        %{state | queue: :queue.in(message, state.queue)}
    end
  end

  defp get_alive_consumer(queue) do
    case :queue.out(queue) do
      {{:value, {pid, _ref}=consumer}, consumers} ->
        if Process.alive?(pid) do
          {{:value, consumer}, consumers}
        else
          get_alive_consumer(consumers)
        end
      {:empty, q} ->
        {:empty, q}
    end
  end


  defp queueing_consumer({pid, ref} = consumer, state) do
    Logger.debug "[#{__MODULE__}] queuing_consumer"

    %{state | consumers: :queue.in(consumer, state.consumers)}
  end

  defp add_unacked(unacked, consumer, {message_id, _} = message) do
    Map.put(unacked, message_id, {consumer, message})
  end

  defp build_message(message) do
    message_id = UUID.uuid1()
    {message_id, message}
  end


  ## Public API
  def declare(name), do: QueueRepository.declare(name)
  # def new(name) when is_binary(name), do: Supervisor.start_child(QueueSup, [%QueueState{name: name}])
  # def new(args \\ %QueueState{}), do: Supervisor.start_child(QueueSup, [args])
  def new(name) when is_binary(name), do: HQueue.Queue.start_link(%QueueState{name: name})
  def new(args \\ %QueueState{}), do: HQueue.Queue.start_link(args)


end
