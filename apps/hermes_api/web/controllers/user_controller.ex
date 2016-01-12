defmodule HApi.UserController do
  use HApi.Web, :controller

  alias HApi.User

  plug :scrub_params, "user" when action in [:create, :update]

  end
