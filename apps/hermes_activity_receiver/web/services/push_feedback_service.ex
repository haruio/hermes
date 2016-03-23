defmodule HActivity.PushFeedbackService do
  alias HActivity.StatsChecker

  @ios_sub_strings ~w(IPHONE IPAD IPOD IOS)

  def received(param) do
    param
    |> build_to_push_feedback_message("RVED")
    |> StatsChecker.add

    %{result: "received"}
  end

  def opened(param) do
    param
    |> build_to_push_feedback_message("OPED")
    |> StatsChecker.add

    ## ios는 opened만 할 수 있어서 receive를 수동으로 넣어준다.
    if is_ios?(param["device"]) do
      param
      |> build_to_push_feedback_message("RVED")
      |> StatsChecker.add
    end

      %{result: "opened"}
  end

  defp is_ios?(device) do
    device
    |> String.upcase
    |> String.contains? @ios_sub_strings
  end


  defp build_to_push_feedback_message(param, stats_cd) do
    now = Ecto.DateTime.utc

    %{
      push_id: param["pushid"],
      ststs_cd: stats_cd,
      stats_cnt: 1,
      stats_start_dt: now,
      stats_end_dt: now,

      status: param["status"],
      uuid: param["uuid"],
      device: param["device"],
      country_code: param["countrycode"],
      app_version: param["appversion"],
      os_version: param["osversion"],
      utc_time: param["utctime"]
    }
  end
end
