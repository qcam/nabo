defmodule Mix.Tasks.Nabo.Gen.Post do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Generates a post"
  @recursive true

  @moduledoc """
  Generates a post with the given path.

  ## Example

      mix nabo.gen.post first-post --path priv/posts

  ## Command line options

  * `-p`, `--path` - the path where the posts locate

  """

  @doc false
  def run(args) do
    switches = [path: :string]
    aliases = [p: :path]

    case OptionParser.parse(args, switches: switches, aliases: aliases) do
      {options, [slug], _invalid} ->
        root_path = Keyword.get(options, :path, "priv/posts/")
        published_at = DateTime.utc_now()
        path = Path.relative_to(root_path, Mix.Project.app_path)
        file = Path.join(path, "#{format_datetime(published_at)}_#{slug}.md")
        create_file(file, post_template(slug: slug, published_at: published_at))

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
