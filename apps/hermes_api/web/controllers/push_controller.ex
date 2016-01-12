defmodule HApi.PushController do
  use HApi.Web, :controller

  alias HApi.PushService

  ## Controller
  def send_push(conn, param) do
    result = case get_push_config(conn) do
               {:ok,config} ->
                 if Map.get(param, "publishTime") == nil do
                   PushService.send_push(config, param)
                 else
                   PushService.reserve_push(config, param)
                 end
               {:error, message} -> %{"error" => message}
               _ -> %{"error" => "unknown error"}
             end

    json conn, result
  end

  def create_message(conn, param) do
    result = case get_push_config(conn) do
               {:ok,config} ->
                 if Map.get(param, "publishTime") == nil do
                   PushService.create_message(config, param)
                 else
                   PushService.create_reserve_message(config, param)
                 end
               {:error, message} -> %{"error" => message}
               _ -> %{"error" => "unknown error"}
             end

    json conn, result
  end

  def send_token(conn, param) do
    result = case get_push_config(conn) do
               {:ok,config} -> PushService.send_token(config, param)
               {:error, message} -> %{"error" => message}
               _ -> %{"error" => "unknown error"}
             end

    json conn, result
  end

  ## Private method
  defp get_push_config(conn) do
    token = get_req_header(conn, "notification-test-token")
    {:ok, %{"service_id" => "0J-6W4i-0O6i-T"}}
  end

end
