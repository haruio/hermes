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
    [applications: [:logger],
     mod: {HPush, []}]
  end

  defp deps do
    [
      # {:hermes_push_store, in_umbrella: true}
      {:exrm, "~> 1.0.0-rc7" },
      {:conform, "~> 1.0.0-rc8"},
      {:conform_exrm, "~> 0.2.0"}
    ]
  end
end
