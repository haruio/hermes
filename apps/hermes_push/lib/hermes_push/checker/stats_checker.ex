defmodule HPush.StatsChecker do
  def add(push_stats), do: HPush.StatsChecker.Buffer.add(push_stats)
end
