defmodule HApi.Router do
  use HApi.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HApi do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", HApi do
    pipe_through :api

    ## push
    post "/push", PushController, :send_push
    post "/push/message", PushController, :create_message
    post "/push/token", PushController, :send_token

  end
end
