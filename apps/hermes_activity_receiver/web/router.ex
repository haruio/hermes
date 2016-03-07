defmodule HActivity.Router do
  use HActivity.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", HActivity do
    pipe_through :api
  end
end
