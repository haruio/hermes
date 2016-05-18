defmodule HWeb.Router do
  use HWeb.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    # plug :protect_from_forgery
    # plug :put_secure_browser_headers
  end

  pipeline :console_check do
    plug HWeb.SessionFilter
  end

  scope "/", HWeb do
    pipe_through :browser # Use the default browser stack

    # landing
    get "/", LandingController, :index
    get "/features", LandingController, :features_page
    get "/overview", LandingController, :overview_page
    get "/document", LandingController, :document_page

    get "/login", UserController, :login_page
    post "/login", UserController, :login

    delete "/logout", UserController, :logout
    post "/logout", UserController, :logout

    get "/signup", UserController, :signup_page
    post "/signup", UserController, :signup

    # get "/document", PageController, :document_page
    scope "/console" do
      pipe_through :console_check

      get "/", ConsoleController, :console_page
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", HWeb do
  #   pipe_through :api
  # end
end
