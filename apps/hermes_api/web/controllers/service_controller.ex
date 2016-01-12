defmodule HApi.ServiceController do
  use HApi.Web, :controller

  alias HApi.Service

  plug :scrub_params, "service" when action in [:create, :update]

 end
