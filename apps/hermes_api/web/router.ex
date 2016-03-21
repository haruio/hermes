defmodule HApi.Router do
  use HApi.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug HApi.TokenChecker
  end

  scope "/api", HApi do
    pipe_through :api

    ## push
    post "/push", PushController, :send_push
    post "/push/message", PushController, :create_message
    post "/push/token", PushController, :send_token

    get  "/push", PushController, :get_push_list
    get  "/push/:id", PushController, :get_push

    ## push reserved
    post "/push/reserved/immediate/:id", PushController, :send_immediate_reserved
    delete "/push/reserved/:id", PushController, :cancel_reserved
    put "/push/reserved/:id", PushController, :update_reserved
  end
end
