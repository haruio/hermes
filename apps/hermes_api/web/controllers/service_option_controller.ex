defmodule HApi.ServiceOptionController do
  use HApi.Web, :controller

  alias HApi.ServiceOption

  plug :scrub_params, "service_option" when action in [:create, :update]

  end
