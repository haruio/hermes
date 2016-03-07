defmodule HActivity.PageController do
  use HActivity.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
