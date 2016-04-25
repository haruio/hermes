defmodule HQueue.Queue do
  use GenServer

  alias HQueue.QueueSup
  alias HQueue.QueueRepository

  require Logger

  @max_retry 2
  @max_timeout  10 * 60 * 1000
  @timer_interval 5 * 60 * 1000

  defmodule  QueueState do
    defstruct name: nil,
    queue: :queue.new,
    unacked: %{},
    consumers: :queue.new,
    timer: nil
  end

  defmodule Message do
    defstruct msg_id: nil,
    try_cnt: 0,
    data: nil,
    consume_date: nil
  end

  ## Public API
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
    Process.flag(:trap_exit, true)
    {:ok, %QueueState{state | timer: add_timer()}}
  end

  def handle_cast({:publish, %Message{}=message}, state) do
    Logger.debug "[#{inspect __MODULE__}] publish"

    {:noreply, queueing_message(message, state)}
  end

  def handle_cast({:publish, message}, state) do
    Logger.debug "[#{inspect __MODULE__}] publish"

    message = build_message(message)
    {:noreply, queueing_message(message, state)}
  end

  def handle_call(:consume, from, state) do
    case :queue.out(state.queue) do
      {{:value, %Message{data: data, msg_id: msg_id}=message}, q} ->
        Logger.debug "[#{inspect __MODULE__}] consume #{inspect message}"
        {:reply, {msg_id, data}, %{state | queue: q, unacked: add_unacked(state.unacked, from, message)}}
      {:empty, _q} ->
        {:noreply, queueing_consumer(from, state)}
    end
  end

  def handle_cast(:publish_unacked, %QueueState{unacked: unacked, queue: queue}=state) do
    Logger.debug("[#{__MODULE__}] publish_unacked (#{inspect state.name}): #{Map.values(unacked) |> length}")

    ## Delete max retry message
    delete_keys = unacked
    |> Map.keys
    |> Enum.filter(fn(msg_id) ->
      {_consumer, %Message{try_cnt: try_cnt}} = Map.get(unacked, msg_id)
      try_cnt > @max_retry
    end)

    new_unacked = Map.drop(unacked, delete_keys)

    ## Republish unacked message
    new_unacked
    |> Map.values
    |> Enum.filter(fn({_consumer, %Message{consume_date: consume_date}=message}) ->
      case Calendar.DateTime.diff(Calendar.DateTime.now_utc, consume_date) do
        {:ok, sec, _msec, :after} when sec > @max_timeout ->
          true
        _ ->
          false
      end
    end)
    |> Enum.each(fn({_consumer, message}) -> GenServer.cast(self, {:publish, message}) end)


    {:noreply, %QueueState{state | unacked: new_unacked}}
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

  def handle_info({:DOWN, ref, :process, pid, _reason}, %QueueState{timer: timer}=state) do
    {_timer_pid, timer_ref} = timer
    if ref == timer_ref do
      Process.demonitor(ref)
      {:noreply, %QueueState{state | timer: add_timer}}
    else
      {:noreply, state}
    end
  end

  def handle_info({:EXIT, pid, _reason}, %QueueState{timer: timer}=state) do
    {timer_pid, timer_ref} = timer
    if pid == timer_pid do
      Process.demonitor(timer_ref)
      {:noreply, %QueueState{state | timer: add_timer}}
    else
      {:noreply, state}
    end
  end

  def terminate(_reason, state) do
    HQueue.QueueStateRepository.insert(state)
  end

  ## Private API
  defp queueing_message(%Message{msg_id: msg_id, data: data, try_cnt: try_cnt}=message, state) do
    Logger.debug "[#{__MODULE__}] queuing_message"

    case get_alive_consumer(state.consumers) do
      {{:value, consumer}, consumers} ->
        GenServer.reply(consumer, {msg_id, data})
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

  defp add_unacked(unacked, consumer, %Message{msg_id: msg_id, try_cnt: try_cnt} = message) do
    Map.put(unacked, msg_id, {consumer, %Message{message | try_cnt: try_cnt+1, consume_date: Calendar.DateTime.now_utc}})
  end

  defp build_message(data) do
    msg_id = UUID.uuid1()

    %Message{msg_id: msg_id, data: data}
  end

  defp add_timer do
    queue = self
    {:ok, timer} = HQueue.QueueTimer.start_link(interval: @timer_interval, callback: fn ->
      {:message_queue_len, len} = Process.info(self, :message_queue_len)
      if len == 0 do
        GenServer.cast(queue, :publish_unacked)
      end
    end)

    ref = Process.monitor(timer)
    {timer, ref}
  end

  ## Public API
  def declare(name), do: QueueRepository.declare(name)
  def new(name) when is_binary(name), do: HQueue.Queue.start_link(%QueueState{name: name})
  def new(args \\ %QueueState{}), do: HQueue.Queue.start_link(args)
end
