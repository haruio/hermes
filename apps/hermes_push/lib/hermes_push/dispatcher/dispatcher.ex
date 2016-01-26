defmodule HPush.Dispatcher do
  use ExActor.GenServer

  @max_chunk 1000

  def pool_name, do: DispatcherPool
  defstart start_link(args \\ %{}) do
    opts = Application.get_env(:hermes_push, __MODULE__, args)
    initial_state(opts)
  end

  def dispatch(job) do
    :poolboy.transaction(pool_name, fn(dispatcher) ->
      GenServer.cast(dispatcher, {:dispatch, job})
    end)
  end
  defcast dispatch(job), state: state do
    message = Map.delete(job, :push_tokens)
    Map.get(job, :push_tokens)
    |> Enum.group_by(fn(token) -> Map.get(token, "pushType") end)
    |> Map.to_list
    |> Enum.each(fn({push_type, tokens}) ->
      dispatch_provider(push_type, tokens, message, state)
    end)

    noreply
  end

  def dispatch_provider(push_type, tokens, message, state) do
    tokens
    |> Stream.map(&(Map.get(&1, "pushToken")))
    |> Stream.chunk(@max_chunk, @max_chunk, [])
    # |> Stream.chunk(1)
    |> Stream.each(fn(chunked_tokens) ->
      IO.inspect chunked_tokens
      case provider_pool_name(push_type, state) do
        {:ok, pool_name} ->
          :poolboy.transaction(pool_name, &(GenServer.cast(&1, {:publish, message, chunked_tokens})))
        :error -> :error
      end
    end)
    |> Stream.run
  end

  defp provider_pool_name(push_type, state) do
    type = push_type
    |> String.downcase
    |> String.to_atom

    case Keyword.fetch(state, type) do
      {:ok, provider} -> {:ok, provider.pool_name}
      :error -> :error
    end
  end

end
