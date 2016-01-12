defmodule HApi.PushOptionController do
  use HApi.Web, :controller

  alias HApi.PushOption

  plug :scrub_params, "push_option" when action in [:create, :update]

  end
