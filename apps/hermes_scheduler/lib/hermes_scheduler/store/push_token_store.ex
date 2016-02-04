defmodule HScheduler.Store.PushTokenStore do
  use ExActor.GenServer, export: __MODULE__

  @default_limit 5000

  defstart start_link(opts) do
    state = %{
      adapter: opts[:adapter],
      store: Keyword.get(opts, :store, opts[:adapter].new(opts))
    }

    initial_state(state)
  end

  def delete(nil), do: :error
  defcall delete(push_id), state: state do
    reply state[:adapter].delete(state[:store], push_id)
  end

  defcall delete_all, state: state do
    reply state[:adapter].delete_all(state[:store])
  end

  defcast add(push_id, tokens), state: state do
    state[:adapter].insert(state[:store], push_id, tokens)

    noreply
  end

  defcall select_all(push_id), state: state do
    reply state[:adapter].select_all(state[:store], push_id)
  end

  defcall next(push_id), when: is_binary(push_id), state: state do
    reply state[:adapter].next(state[:store], push_id, @default_limit)
  end

  defcall next(cursor), state: state do
    reply state[:adapter].next(state[:store], cursor)
  end

  defcall status, state: state do
    reply :ets.info(state[:store])
  end

end
