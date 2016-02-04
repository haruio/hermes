defmodule HScheduler.Repo do
  use Ecto.Repo, otp_app: :hermes_scheduler
  use Scrivener, page_size: 50
end
