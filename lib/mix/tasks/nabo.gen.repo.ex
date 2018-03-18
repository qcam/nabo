defmodule Mix.Tasks.Nabo.Gen.Repo do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Generates a repo"
  @recursive true

  @moduledoc """
  Generates a repo.

  ## Example

      mix nabo.gen.repo MyApp.Repo

  """

  @doc false
  def run(args) do
    case OptionParser.parse(args) do
      {_, [repo], _} ->
        underscored = Macro.underscore(repo)
        file = Path.join("lib", underscored) <> ".ex"

        create_directory(Path.dirname(file))
        create_file(file, repo_template(mod: repo))

      _ ->
        Mix.raise "expected nabo.gen.repo to receive repo name, " <>
                  "got: #{inspect Enum.join(args, " ")}"
    end
  end

  embed_template :repo, """
  defmodule <%= @mod %> do
    use Nabo.Repo, root: "priv/posts"
  end
  """
end
