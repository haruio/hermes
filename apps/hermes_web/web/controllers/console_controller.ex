defmodule HWeb.ConsoleController do
  use HWeb.Web, :controller

  plug :put_layout, "console_layout.html"

  def console_page(conn, params) do
    render conn, "console.html"
  end
end
