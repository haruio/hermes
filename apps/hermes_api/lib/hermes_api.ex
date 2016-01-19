defmodule HApi do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(HApi.Endpoint, []),
      supervisor(HApi.Repo, []),
      supervisor(Producer.ProducerSup, [])
      # worker(Producer.PushProducer, []) # TODO change to poolboy
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HApi.Endpoint.config_change(changed, removed)
    :ok
  end
end
