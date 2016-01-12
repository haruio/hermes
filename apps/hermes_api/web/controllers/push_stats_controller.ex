defmodule HApi.PushStatsController do
  use HApi.Web, :controller

  alias HApi.PushStats

  plug :scrub_params, "push_stats" when action in [:create, :update]


end
