defmodule Hermes.Mixfile do
  use Mix.Project

  def project do
    [apps_path: "apps",
     version: "0.0.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    [
      {:exrm, "~> 1.0.0-rc7" },
      {:conform, "~> 1.0.0-rc8"},
      {:conform_exrm, "~> 0.2.0"}
    ]
  end
end
