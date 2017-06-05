defmodule Nabo.Compilers.Markdown do
  alias Nabo.Post

  @behaviour Nabo.Compiler

  @moduledoc """
  The default compiler in `Nabo`, for `Nabo.Post` format compliant post.

  `Nabo.Compilers.Markdown` uses `Earmark` as its markdown compiler.

  The first element of the returned tuple is the identifier of the post.
  """

  @doc """
  Compiles a raw content that complies with `Nabo.Post` format into macro.

  ## Options

  * `markdown` - (`Earmark.Options`) options to pass to Earmark markdown parsing function.

  """
  @spec compile(content :: String.t, options :: Keyword.t) :: {identifier :: String.t, compiled :: Marco.t}
  def compile(content, options \\ []) when is_binary(content) do
    case Post.from_string(content) do
      {:ok, post} ->
        excerpt_html = parse_markdown(post.excerpt, options)
        body_html = parse_markdown(post.body, options)
        compiled = post
                   |> Post.put_excerpt_html(excerpt_html)
                   |> Post.put_body_html(body_html)
                   |> Macro.escape

        {post.slug, compiled}
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_markdown(markdown, options) do
    {markdown_options, _} = Keyword.pop(options, :markdown, %Earmark.Options{})
    Earmark.as_html!(markdown, markdown_options)
  end
end
