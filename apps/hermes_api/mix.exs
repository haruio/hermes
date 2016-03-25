defmodule HApi.Mixfile do
  use Mix.Project

  def project do
    [app: :hermes_api,
     version: "0.0.1",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {HApi, []},
      applications: [:phoenix, :phoenix_html, :cowboy, :logger, :gettext,
                     :phoenix_ecto, :mariaex, :calendar,
                     :exactor, :timex] ++ env_applications(Mix.env)
    ]
  end

  def env_applications(:test), do: [:hermes_queue]
  def env_applications(:prod_kr), do: [:hermes_queue]
  def env_applications(:prod), do: [:hermes_queue]
  def env_applications(:local), do: [:hermes_queue]
  def env_applications(_), do: []

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.1.0"},
     {:phoenix_ecto, "~> 2.0"},
     {:mariaex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.3"},
     {:phoenix_live_reload, "~> 1.0", only: [:local]},
     {:gettext, "~> 0.9"},
     {:timex, "~> 1.0.0-rc3"},
     {:exactor, "~> 2.2"},
     {:exrm, "~> 1.0"},
     {:conform, "~> 2.0"},
     {:conform_exrm, "~> 1.0"},
     {:calendar, "~> 0.12.4"},
     {:hermes_queue, in_umbrella: true, only: [:local, :test, :prod_kr, :prod]},
     {:scrivener, "~> 1.1"},
     {:cowboy, "~> 1.0"}]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"]]
  end
end
