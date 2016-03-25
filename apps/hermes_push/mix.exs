defmodule HPush.Mixfile do
  use Mix.Project

  def project do
    [app: :hermes_push,
     version: "0.0.1",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :gcm, :apns,
                    :poolboy, :poison, :httpoison, :exactor, :ecto, :mariaex] ++ env_applications(Mix.env),
     mod: {HPush, []}]
  end

  def env_applications(:test), do: [:hermes_queue]
  def env_applications(:local), do: [:hermes_queue]
  def env_applications(:prod_kr), do: [:hermes_queue]
  def env_applications(_), do: []

  defp deps do
    [
      {:poolboy, "~> 1.5"},
      {:poison, "~> 1.5"},
      {:httpoison, "~> 0.8.0"},
      {:exactor, "~> 2.2"},
      {:gcm, "~> 1.1"},
      {:apns, "~> 0.0.12"},
      {:ecto, "~> 1.1"},
      {:mariaex, "~> 0.6.2"},
      {:exrm, "~> 1.0"},
      {:conform, "~> 2.0"},
      {:conform_exrm, "~> 1.0"},
      {:hermes_queue, in_umbrella: true, only: [:local, :test, :prod_kr]}
    ]
  end
end
