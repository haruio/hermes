defmodule HActivity.Router do
  use HActivity.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/v1/feedback", HActivity do
    pipe_through :api

    post "/:id/received", PushFeedbackController, :received
    post "/:id/opened", PushFeedbackController, :opened
  end
end
