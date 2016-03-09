defmodule HActivity.StatsChecker do
  def add(push_stats), do: HActivity.StatsChecker.Buffer.add(push_stats)
end
