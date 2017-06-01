defmodule Nabo.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [app: :nabo,
     version: @version,
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     name: "Nabo",
     deps: deps()]
  end

  def application do
    [application: [:logger]]
  end

  defp deps do
    [
      {:cowboy, "~> 1.1.2"},
      {:plug, "~> 1.3.4"},
      {:earmark, "~> 1.2.2"},
      {:poison, "~> 3.1.0"},
    ]
  end

  defp package do
    [maintainers: ["Cẩm Huỳnh"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/qcam/nabo"},
     files: ~w(mix.exs README.md lib priv)]
  end

  defp description do
    """
    A simple blog engine for Elixir
    """
  end
end
