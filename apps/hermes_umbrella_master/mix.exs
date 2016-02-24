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

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :hermes_queue, :hermes_api, :hermes_push, :hermes_scheduler, :conform, :conform_exrm]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:myapp, in_umbrella: true}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:exrm, "~> 1.0.0-rc7" },
      {:conform, "~> 1.0.0-rc8"},
      {:conform_exrm, "~> 0.2.0"},
      {:hermes_queue, in_umbrella: true},
      {:hermes_api, in_umbrella: true},
      {:hermes_push, in_umbrella: true},
      {:hermes_scheduler, in_umbrella: true}
    ]
  end
end
