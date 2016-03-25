defmodule HUmbrellaMaster.Mixfile do
  use Mix.Project

  def project do
    [app: :hermes_umbrella_master,
     version: "0.0.1",
     config_path: "./config/config.exs",
     deps_path: "./deps",
     lockfile: "./mix.lock",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [
      applications: [:logger,
                     :hermes_api,
                     :hermes_push,
                     :hermes_scheduler,
                     :conform,
                     :conform_exrm] ++ env_applications(Mix.env)
    ]
  end

  def env_applications(:prod_kr), do: [:hermes_activity_receiver]
  def env_applications(_), do: []

  defp deps do
    [
      {:exrm, "~> 1.0"},
      {:conform, "~> 2.0"},
      {:conform_exrm, "~> 1.0"},
      {:hermes_api, in_umbrella: true},
      {:hermes_push, in_umbrella: true},
      {:hermes_scheduler, in_umbrella: true},
      {:hermes_activity_receiver, in_umbrella: true, only: [:prod_kr]}
    ]
  end
end
