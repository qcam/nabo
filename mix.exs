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
      {:earmark, "~> 1.2.2"},
      {:poison, "~> 3.1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end

  defp package do
    [maintainers: ["Cẩm Huỳnh"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/qcam/nabo"},
     files: ~w(mix.exs README.md lib)]
  end

  defp description do
    """
    A dead simple, extendable and fast blog engine in Elixir
    """
  end
end
