defmodule Nabo.Compilers.Markdown do
  alias Nabo.Post

  @behaviour Nabo.Compiler

  @doc """
  Compile a raw post that compliant to Nabo post format into macro.

  The first element of the returned tuple is the identifier of the post.
  """
  @spec compile(content :: String.t) :: {identifier :: String.t, compiled :: Marco.t}
  def compile(content) when is_binary(content) do
    {:ok, post} = Post.from_string(content)
    excerpt_html = Earmark.as_html!(post.excerpt)
    body_html = Earmark.as_html!(post.body)
    compiled = post
               |> Post.put_excerpt_html(excerpt_html)
               |> Post.put_body_html(body_html)
               |> Macro.escape

    {post.slug, compiled}
  end
end
