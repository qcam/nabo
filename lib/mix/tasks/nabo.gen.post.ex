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
        datetime = DateTime.utc_now()
        posts_path = "priv/posts"
        path = Path.relative_to(posts_path, Mix.Project.app_path)
        file = Path.join(path, "#{format_datetime(datetime)}_#{slug}.md")
        create_file(file, post_template(slug: slug, datetime: datetime))
      _ ->
        Mix.raise "expected nabo.gen.post to receive post slug, " <>
                  "got: #{inspect(Enum.join(args, " "))}"
    end
  end

  def format_datetime(datetime) do
    [
      datetime.year,
      pad_string(datetime.month),
      pad_string(datetime.day),
      pad_string(datetime.hour),
      pad_string(datetime.minute),
      pad_string(datetime.second),
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
    "datetime": "<%= DateTime.to_iso8601(@datetime) %>"
  }
  ---
  """
end
