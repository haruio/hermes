defmodule HApi.PushController do
  use HApi.Web, :controller

  alias HApi.Service.Query, as: ServiceQuery
  alias HApi.PushService

  ## Controller
  def send_push(conn, param) do
    result = case get_push_service(conn) do
               {:ok,service} ->
                 if Map.get(param, "publishTime") == nil do
                   PushService.publish_push(:immediate, service, param)
                 else
                   PushService.publish_push(:reserve, service, param)
                 end
               {:error, message} -> %{"error" => message}
               _ -> %{"error" => "unknown error"}
             end

    json conn, result
  end

  def create_message(conn, param) do
    result = case get_push_service(conn) do
               {:ok,service} ->
                 if Map.get(param, "publishTime") == nil do
                   PushService.create_message(:immediate, service, param)
                 else
                   PushService.create_message(:reserve, service, param)
                 end
               {:error, message} -> %{"error" => message}
               _ -> %{"error" => "unknown error"}
             end

    json conn, result
  end

  def send_token(conn, param) do
    result = case get_push_service(conn) do
               {:ok, service} -> PushService.send_token(service, param)
               {:error, message} -> %{"error" => message}
               _ -> %{"error" => "unknown error"}
             end
    json conn, result
  end

  def cancel_reserved(conn, param) do
    result = case get_push_service(conn) do
               {:ok, service} -> PushService.cancel_reserved(service, param)
               {:error, message} -> %{"error" => message}
               _ -> %{"error" => "unknown error"}
             end

    json conn, result
  end

  def update_reserved(conn, param) do
    result = case get_push_service(conn) do
               {:ok, service} -> PushService.update_reserved(service, param)
               {:error, message} -> %{"error" => message}
               _ -> %{"error" => "unknown error"}
             end

    json conn, result
  end

  def send_immediate_reserved(conn, param) do
    result = case get_push_service(conn) do
               {:ok, service} -> PushService.send_immediate(service, param)
               {:error, message} -> %{"error" => message}
               _ -> %{"error" => "unknown error"}
             end

    json conn, result
  end

  def get_push_list(conn, param) do
    result = case get_push_service(conn) do
               {:ok, service} -> PushService.get_push_list(service, param)
               {:error, message} -> %{"error" => message}
               _ -> %{"error" => "unknown error"}
             end
    json conn, result
  end

  def get_push(conn, param) do
    result = case get_push_service(conn) do
               {:ok, service} -> PushService.get_push(service, param)
               {:error, message} -> %{"error" => message}
               _ -> %{"error" => "unknown error"}
             end
    json conn, result
  end

  ## Private method
  defp get_push_service(conn) do
    service = get_req_header(conn, "notification-rest-token")
    |> ServiceQuery.select_one_by_rest_token

    {:ok, service}
  end

end
