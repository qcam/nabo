defmodule Nabo.Mixfile do
  use Mix.Project

  @version "0.0.4"

  def project do
    [app: :nabo,
     version: @version,
     elixir: "~> 1.4",
     deps: deps(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     name: "Nabo",
     docs: [source_ref: "v#{@version}",
            main: "Nabo",
            canonical: "http://hexdocs.pm/nabo",
            source_url: "https://github.com/qcam/nabo"]]
  end

  def application do
    [application: [:logger]]
  end

  defp deps do
    [
      {:earmark, "~> 1.1.0"},
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
