defmodule HPush.StatsChecker.Buffer do
  use ExActor.GenServer, export: __MODULE__

  alias HPush.Model.PushStats.Query, as: PushStatsQuery

  defstart start_link(buff \\ []) do
    initial_state(buff)
  end

  defcast add(message), state: buff do
    new_state(buff ++ [message])
  end

  defcast flush, state: buff do
    Task.async(fn ->
      buff
      |> Enum.reduce(%{}, &reduce_stats/2)
      |> Map.values
      |> Enum.each(&PushStatsQuery.insert/1)
    end)

    new_state([])
  end

  defp reduce_stats(stats, acc) do
    case Map.get(acc, stats[:push_id]) do
      nil ->
        Map.put(acc, stats[:push_id], stats)
      acc_stats ->
        Map.put(acc, stats[:push_id], %{push_id: acc_stats[:push_id],
                                        ststs_cd: acc_stats[:ststs_cd],
                                        stats_cnt: acc_stats[:stats_cnt] + stats[:stats_cnt],
                                        stats_start_dt: acc_stats[:stats_start_dt],
                                        stats_end_dt: stats[:stats_end_dt]})
    end
  end
end
