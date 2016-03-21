defmodule HApi.PushController do
  use HApi.Web, :controller

  alias HApi.PushService

  def send_push(conn, param) do
    service = conn.assigns[:service]
    result = case  Map.get(param, "publishTime") do
               nil -> PushService.publish_push(:immediate, service, param)
               _ -> PushService.publish_push(:reserve, service, param)
             end

    send_json conn, result
  end

  def create_message(conn, param) do
    service = conn.assigns[:service]
    result = case  Map.get(param, "publishTime") do
               nil -> PushService.create_message(:immediate, service, param)
               _ -> PushService.create_message(:reserve, service, param)
             end

    send_json conn, result
  end

  def send_token(conn, param) do
    service = conn.assigns[:service]
    result = PushService.send_token(service, param) # TODO {:ok, _} | {:error, reason}

    send_json conn, result
  end

  def cancel_reserved(conn, param) do
    service = conn.assigns[:service]
    result = PushService.cancel_reserved(service, param) # TODO {:ok, _} | {:error, reason}

    send_json conn, result
  end

  def update_reserved(conn, param) do
    service = conn.assigns[:service]
    result = PushService.update_reserved(service, param) # TODO {:ok, _} | {:error, reason}

    send_json conn, result
  end

  def send_immediate_reserved(conn, param) do
    service = conn.assigns[:service]
    result = PushService.send_immediate(service, param) # TODO {:ok, _} | {:error, reason}

    send_json conn, result
  end

  def get_push_list(conn, param) do
    service = conn.assigns[:service]
    result = PushService.get_push_list(service, param) # TODO {:ok, _} | {:error, reason}

    send_json conn, result
  end

  def get_push(conn, param) do
    service = conn.assigns[:service]
    result = PushService.get_push(service, param) # TODO {:ok, _} | {:error, reason}

    send_json conn, result
  end

end
