defmodule Mix.Tasks.Nabo.Gen.Post do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Generates a post"
  @recursive true

  @moduledoc """
  Generates a post for the given repo.

  ## Example

      mix nabo.gen.post first-post --repo MyRepo

  ## Command line options

  * `--repo` - the repo to which the post belongs

  """

  @doc false
  def run(args) do
    switches = [repo: :string]
    aliases = [r: :repo]

    case OptionParser.parse(args, switches: switches, aliases: aliases) do
      {options, [slug], _invalid} ->
        repo =
          options
          |> Keyword.fetch!(:repo)
          |> List.wrap()
          |> Module.concat()
          |> ensure_repo(args)

        published_at = DateTime.utc_now()
        file_name = DateTime.to_iso8601(published_at, :basic) <> "_" <> slug <> ".md"

        repo.__options__()
        |> Keyword.fetch!(:root)
        |> Path.relative_to_cwd()
        |> Path.join(file_name)
        |> create_file(post_template(slug: slug, published_at: published_at))

      _ ->
        Mix.raise("nabo.gen.post expects a slug, got: #{inspect(args)}")
    end
  end

  defp ensure_repo(repo, args) do
    Mix.Task.run("loadpaths", args)
    Mix.Task.run("compile", args)

    case Code.ensure_loaded(repo) do
      {:module, repo} ->
        if function_exported?(repo, :__options__, 0) do
          repo
        else
          Mix.raise("#{inspect(repo)} is not a Nabo.Repo")
        end

      {:error, reason} ->
        Mix.raise("Could not load #{inspect(repo)} due to #{inspect(reason)}")
    end
  end

  embed_template :post, """
  {
    "title": "",
    "slug": "<%= @slug %>",
    "published_at": "<%= DateTime.to_iso8601(@published_at) %>"
  }
  ---
  """
end
