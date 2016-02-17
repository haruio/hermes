defmodule HApi.Repo do
  use Ecto.Repo, otp_app: :hermes_api
  use Scrivener, page_size: 10
end
