defmodule HApi.ResponseHelpers do
  import Phoenix.Controller, only: [json: 2]

  @empty_obj %{}

  def send_json(conn, {:error, reason}) when is_binary(reason) do
    send_json conn, {:error, %{ message: reason, status: 400}}
  end

  def send_json(conn, {:error, error}) when is_map(error) do
    json conn, error |> Map.take([:message, :status])
  end

  def send_json(conn, model) when is_map(model) do
    json conn, model
  end

  def send_json(conn, :ok) do
    json conn, @empty_obj
  end

  def send_json(conn, _) do
    json conn, @empty_obj
  end
end
