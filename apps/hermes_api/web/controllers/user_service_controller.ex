defmodule HApi.UserServiceController do
  use HApi.Web, :controller

  alias HApi.UserService

  plug :scrub_params, "user_service" when action in [:create, :update]

end
