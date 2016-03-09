defmodule HActivity.StatsChecker.Buffer do
  use ExActor.GenServer, export: __MODULE__

  alias HActivity.PushStats.Query, as: PushStatsQuery

  defstart start_link(buff \\ []) do
    initial_state(buff)
  end

  defcast add(message), state: buff do
    insert_splunk(message)

    new_state(buff ++ [message])
  end

  defcast flush, state: buff do
    insert_db(buff)

    new_state([])
  end

  defp insert_db([]), do: :ok
  defp insert_db(buff) do
    Task.async(fn ->
      buff
      |> Enum.reduce(%{}, &reduce_stats/2)
      |> Map.values
      |> Enum.each(&PushStatsQuery.insert/1)
    end)
  end

  defp insert_splunk([]), do: :ok
  defp insert_splunk(buff) when is_list(buff) do
    Task.async(fn ->
      buff
      |> Enum.reduce("", &reduce_stats_to_binary/2)
      |> send_to_splunk
    end)
  end

  defp insert_splunk(stats) do
    stats
    |> build_stats
    |> Splunk.ConnectionPool.send
  end

  defp reduce_stats(stats, acc) do
    key = stats_merge_key(stats)

    case Map.get(acc, key) do
      nil ->
        Map.put(acc, key, stats)
      acc_stats ->
        Map.put(acc, key, %{push_id: acc_stats[:push_id],
                            ststs_cd: acc_stats[:ststs_cd],
                            stats_cnt: acc_stats[:stats_cnt] + stats[:stats_cnt],
                            stats_start_dt: acc_stats[:stats_start_dt],
                            stats_end_dt: stats[:stats_end_dt]})
    end
  end

  defp stats_merge_key(stats), do: stats[:push_id] <> stats[:ststs_cd]

  defp build_stats(stats) do
    Poison.encode!(stats) <> "\u000A"
  end

  defp reduce_stats_to_binary(stats, acc) do
    build_stats(stats) <> acc
  end

  defp send_to_splunk(binary) when is_binary(binary) do
    IO.inspect binary
    options = [:binary, active: false]
    {:ok, socket} = :gen_tcp.connect('mailfeed.makeusmobile.com', 9998, options)
    :ok = :gen_tcp.send(socket, binary)
    :gen_tcp.close(socket)
  end
end
