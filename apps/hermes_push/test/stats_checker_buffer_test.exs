defmodule StatsCheckerBufferTest do
  use ExUnit.Case

  alias HPush.StatsChecker.Buffer

  test "test" do
    Buffer.start_link

    Enum.each(1..5, &(Buffer.add(%{push_id: "PUSHID " <> to_string(&1),
                                   ststs_cd: "CD",
                                   stats_cnt: &1,
                                   stats_start_dt: Ecto.DateTime.utc,
                                   stats_end_dt: Ecto.DateTime.utc})))
    Enum.each(1..5, &(Buffer.add(%{push_id: "PUSHID " <> to_string(&1),
                                   ststs_cd: "CD",
                                   stats_cnt: &1,
                                   stats_start_dt: Ecto.DateTime.utc,
                                   stats_end_dt: Ecto.DateTime.utc})))
    Buffer.flush
    Enum.each(1..5, &(Buffer.add(%{push_id: "PUSHID " <> to_string(&1),
                                   ststs_cd: "CD",
                                   stats_cnt: &1,
                                   stats_start_dt: Ecto.DateTime.utc,
                                   stats_end_dt: Ecto.DateTime.utc})))
    Buffer.flush

    :timer.sleep 100
    assert 1 == 1
  end
end
