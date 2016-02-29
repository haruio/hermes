defmodule HScheduler.Store.ETSAdapter do
  def new(opts), do: :ets.new(opts[:name], opts[:opts])

  def insert(ets, key, value) do
    :ets.insert(ets, {key, value})
  end

  def delete(ets, key) do
    :ets.delete(ets, key)
  end

  def delete_all(ets) do
    :ets.delete_all_objects(ets)
  end

  def select_all(ets, key) do
    :ets.lookup(ets, key)
  end

  def next(ets, key, limit) when is_binary(key) do
    {tokens, cursor} = :ets.select(ets, by_key(key), limit)
    IO.inspect cursor
  end

  def next(ets, cursor) when is_tuple(cursor) do
    :ets.select(ets, cursor)
  end

  defp by_key(key) do
    [{
      {:"$1", :"$2"},
      [{:andalso, {:==, :"$1", key}}],
      [:"$2"]
      }]
  end
end
