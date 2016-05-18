defmodule HWeb.SessionFilter do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]

  def init(opts) do
    opts
  end

  def call(conn, param) do
    case check_session(conn) do
      {:ok, user_info} ->
        assign(conn, :user_info, user_info)
      {:error, _message} ->
        conn
        |> redirect(to: "/login")
    end
  end

  defp check_session(conn) do
    case get_session(conn, :user_info) do
      nil -> {:error, "Missing session"}
      user_info -> {:ok, user_info}
    end
  end
end
