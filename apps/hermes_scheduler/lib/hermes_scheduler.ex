defmodule HScheduler do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
       worker(HScheduler.Repo, []),
       supervisor(HScheduler.Store.StoreSup, []),
       supervisor(HScheduler.Job.JobSup, []),
       supervisor(HScheduler.Producer.ProducerSup, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HScheduler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
