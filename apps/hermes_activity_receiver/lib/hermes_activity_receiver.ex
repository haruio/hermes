defmodule HActivity do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    splunk_env = Application.get_env(:hermes_activity_receiver, Splunk)

    children = [
      supervisor(HActivity.Endpoint, []),
      supervisor(HActivity.Repo, []),
      supervisor(HActivity.CheckerSup, []),
      supervisor(Splunk.ConnectionPool, [splunk_env])
    ]


    opts = [strategy: :one_for_one, name: HActivity.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    HActivity.Endpoint.config_change(changed, removed)
    :ok
  end
end
