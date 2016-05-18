defmodule HWeb.UserController do
  use HWeb.Web, :controller

  plug :put_layout, "app.html"

  def login_page(conn, param) do
    render conn, "login.html"
  end

  def login(conn, param) do
    conn
    |> put_session(:user_info, %{user_name: "syntaxfish"})
    |> redirect(to: console_path(conn, :console_page))
  end

  def signup_page(conn, param) do
    render conn, "signup.html"
  end

  def signup(conn, param) do
    conn
    |> redirect(to: user_path(conn, :login))
  end

  def logout(conn, _param) do
    case get_session(conn, :user_info) do
      nil -> redirect(conn, to: landing_path(conn, :index))
      user_info ->
        conn
        |> clear_session
        |> redirect(to: landing_path(conn, :index))
    end
  end
end
