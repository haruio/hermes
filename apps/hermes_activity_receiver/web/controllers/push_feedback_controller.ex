defmodule HActivity.PushFeedbackController do
  use HActivity.Web, :controller

  alias HActivity.PushFeedbackService

  defmodule PushFeedbackMessage do
    defstruct [ push_id: nil,
                stats_cd: nil,
                stats_cnt: 1,
                stats_start_dt: nil,
                stats_end_dt: nil,
                status: nil,
                uuid: nil,
                device: nil,
                country_code: nil,
                app_version: nil,
                os_version: nil,
                utc_time: nil]
  end

  def received(conn, param) do
    result = param
    |> build_to_push_feedback_message("RVED")
    |> PushFeedbackService.received

    json conn, result
  end

  def opened(conn, param) do
    result = param
    |> build_to_push_feedback_message("OPED")
    |> PushFeedbackService.opened

    json conn, result
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
