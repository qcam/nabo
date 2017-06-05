defmodule Mix.Tasks.Nabo.Gen.Post do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Generates a post"
  @recursive true

  @moduledoc """
  Generates a post.

  ## Example

      mix nabo.gen.post first-post

  """

  @doc false
  def run(args) do
    case OptionParser.parse(args) do
      {_, [slug], _} ->
        date = Date.utc_today()
        posts_path = "priv/posts"
        path = Path.relative_to(posts_path, Mix.Project.app_path)
        file = Path.join(path, "#{date}_#{slug}.md")
        create_file(file, post_template(slug: slug, date: date))
      _ ->
        Mix.raise "expected nabo.gen.post to receive post slug, " <>
                  "got: #{inspect(Enum.join(args, " "))}"
    end
  end

  embed_template :post, """
  {
    "title": "",
    "slug": "<%= @slug %>",
    "date": "<%= @date %>"
  }
  ---
  """
end
