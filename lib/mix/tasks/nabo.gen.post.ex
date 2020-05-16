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

        case Code.ensure_loaded(repo) do
          {:module, repo} ->
            published_at = DateTime.utc_now()

            options = repo.__options__()
            file_path =
              options
              |> Keyword.fetch!(:root)
              |> Path.relative_to_cwd()
              |> Path.join("#{format_datetime(published_at)}_#{slug}.md")

            create_file(file_path, post_template(slug: slug, published_at: published_at))

          {:error, reason} ->
            Mix.raise("#{inspect(repo)} is not a repo")
        end

      _ ->
        Mix.raise "expected nabo.gen.post to receive post slug, " <>
                  "got: #{inspect(Enum.join(args, " "))}"
    end
  end

  defp format_datetime(published_at) do
    [
      published_at.year,
      pad_string(published_at.month),
      pad_string(published_at.day),
      pad_string(published_at.hour),
      pad_string(published_at.minute),
      pad_string(published_at.second),
    ] |> Enum.join("")
  end

  defp pad_string(integer) do
    integer
    |> Integer.to_string
    |> String.pad_leading(2, "0")
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
