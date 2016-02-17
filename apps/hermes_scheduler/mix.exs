defmodule HScheduler.Mixfile do
  use Mix.Project

  def project do
    [app: :hermes_scheduler,
     version: "0.0.1",
     # build_path: "../../_build",
     # config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :quantum, :ecto, :mariaex, :hermes_queue,
                   :exactor, :scrivener],
     mod: {HScheduler, []}]
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
      {:quantum, "~> 1.6"},
      {:scrivener, "~> 1.1"},
      {:ecto, "~> 1.0"},
      {:mariaex, "~> 0.6.2"},
      {:exactor, "~> 2.2"},
      {:poolboy, "~> 1.5"},
      {:hermes_queue, in_umbrella: true},
      {:exrm, "~> 1.0.0-rc7" },
      {:conform, "~> 1.0.0-rc8"},
      {:conform_exrm, "~> 0.2.0"}
    ]
  end
end
