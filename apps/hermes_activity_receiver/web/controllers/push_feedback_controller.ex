defmodule HActivity.PushFeedbackController do
  use HActivity.Web, :controller

  alias HActivity.PushFeedbackService

  def received(conn, param) do
    result = param
    |> Map.take(["pushid", "status", "uuid", "device", "country_code", "appversion", "osversion", "utctime"])
    |> PushFeedbackService.received

    json conn, result
  end

  def opened(conn, param) do
    result = param
    |> Map.take(["pushid", "status", "uuid", "device", "country_code", "appversion", "osversion", "utctime"])
    |> PushFeedbackService.opened

    json conn, result
  end
end
