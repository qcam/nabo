defmodule Nabo.Mixfile do
  use Mix.Project

  @version "2.0.0"

  def project() do
    [
      app: :nabo,
      version: @version,
      elixir: "~> 1.6",
      deps: deps(),
      description: description(),
      package: package(),
      name: "Nabo",
      docs: [
        source_ref: "v#{@version}",
        main: "Nabo",
        canonical: "http://hexdocs.pm/nabo",
        source_url: "https://github.com/qcam/nabo"
      ]
    ]
  end

  def application(), do: []

  defp deps() do
    [
      {:earmark, "~> 1.4", optional: true},
      {:jason, "~> 1.0", optional: true},
      {:ex_doc, "~> 0.19", only: :dev}
    ]
  end

  defp package() do
    [
      maintainers: ["Cẩm Huỳnh"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/qcam/nabo"},
      files: ~w(mix.exs README.md lib)
    ]
  end

  defp description() do
    """
    A dead simple, extendable and fast blog engine in Elixir
    """
  end
end
