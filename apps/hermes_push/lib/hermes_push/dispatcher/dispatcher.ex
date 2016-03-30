defmodule HPush.Dispatcher do
  use ExActor.GenServer

  require Logger

  defmodule State do
    defstruct opts: nil, queue: nil
  end

  @max_chunk 1000
  @queue_name "local.push.publish.data"

  def pool_name, do: DispatcherPool

  defstart start_link(args \\ %{}) do
    {:ok, queue} = HQueue.Queue.declare(@queue_name)
    state = %State{
      opts: Application.get_env(:hermes_push, __MODULE__),
      queue: queue
    }

    Process.monitor(queue)

    GenServer.cast(self, :consume)


    initial_state(state)
  end

  def dispatch(job) do
    Logger.debug "[#{__MODULE__}] dispatch"

    :poolboy.transaction(pool_name, fn(dispatcher) ->
      GenServer.cast(dispatcher, {:dispatch, job})
    end)
  end

  defcast consume, state: state do
    Logger.debug "[#{__MODULE__}] handle_cast consume"

    if Process.alive?(state.queue) do
      {msg_id, message} = HQueue.Queue.consume(state.queue)
      GenServer.cast(self, {:dispatch, message})
      HQueue.Queue.ack(state.queue, msg_id)
      GenServer.cast(self, :consume)
    end

    noreply
  end

  defcast dispatch(job), state: state do
    Logger.debug "[#{__MODULE__}] handle_cast dispatch"

    HPush.StatusCheker.check(job.push_id, length(job.push_tokens))
    message = Map.delete(job, :push_tokens)
    Map.get(job, :push_tokens)
    |> Enum.group_by(fn(token) -> Map.get(token, "pushType") end)
    |> Map.to_list
    |> Enum.each(fn({push_type, tokens}) ->
      dispatch_provider(push_type, tokens, message, state.opts)
    end)

    noreply
  end


  def handle_info({:DOWN, ref, :process, pid, :noproc}, state) do
    if state.queue == pid do
      Logger.debug "[#{__MODULE__}] new queue"
      Process.demonitor(ref)
      {:ok, queue} = HQueue.Queue.declare(@queue_name)
      Process.monitor(queue)
      GenServer.cast(self, :consume)
      {:noreply, %State{state | queue: queue}}
    else
      {:noreply, state}
    end
  end

  def dispatch_provider(push_type, tokens, message, opts) do
    Logger.debug "[#{__MODULE__}] dispatch_provider"

    tokens
    |> Stream.map(&(Map.get(&1, "pushToken")))
    |> Stream.chunk(@max_chunk, @max_chunk, [])
    |> Stream.each(fn(chunked_tokens) ->
      case provider_pool_name(push_type, opts) do
        {:ok, pool_name} ->
          :poolboy.transaction(pool_name, &(GenServer.cast(&1, {:publish, message, chunked_tokens})))
        :error -> :error
      end
    end)
    |> Stream.run
  end

  defp provider_pool_name(push_type, opts) do
    type = push_type
    |> String.downcase
    |> String.to_atom

    case Keyword.fetch(opts, type) do
      {:ok, provider} -> {:ok, provider.pool_name}
      :error -> :error
    end
  end
end
