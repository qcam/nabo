defmodule Mix.Tasks.Nabo.Gen.Post do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Generates a post"
  @recursive true

  @moduledoc """
  Generates a post.

  ## Example

      mix nabo.gen.post "Title of Post."

  """

  @doc false
  def run(args) do
    case OptionParser.parse(args) do
      {_, [title], _} ->
        slug =
          title
          |> String.downcase()
          |> String.replace(".", "")
          |> String.replace("'", "")
          |> String.replace(~r/[^\w-]+/u, "-")

        datetime = DateTime.utc_now()
        posts_path = "priv/posts"
        path = Path.relative_to(posts_path, Mix.Project.app_path)
        file = Path.join(path, "#{format_datetime(datetime)}_#{slug}.md")
        create_file(file, post_template(title: title, slug: slug, datetime: datetime))
      _ ->
        Mix.raise "expected nabo.gen.post to receive post title, " <>
                  "got: #{inspect(Enum.join(args, " "))}"
    end
  end

  defp format_datetime(datetime) do
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
    "title": "<%= @title %>",
    "slug": "<%= @slug %>",
    "datetime": "<%= DateTime.to_iso8601(@datetime) %>"
  }
  ---
  """
end
