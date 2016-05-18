defmodule HWeb.LandingController do
  use HWeb.Web, :controller

  def index(conn, _param) do
    render conn, "index.html"
  end

  def overview_page(conn, _param) do
    render conn, "overview.html"
  end

  def features_page(conn, _param) do
    render conn, "features.html"
  end

  def document_page(conn, _param) do
    render conn, "document.html"
  end
end
