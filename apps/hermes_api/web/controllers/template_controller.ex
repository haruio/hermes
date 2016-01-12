defmodule HApi.TemplateController do
  use HApi.Web, :controller

  alias HApi.Template

  plug :scrub_params, "template" when action in [:create, :update]

end
