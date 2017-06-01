defmodule Nabo.Post do
  alias Nabo.FrontMatter

  defstruct [:title, :slug, :date, :excerpt, :excerpt_html, :body, :body_html, :metadata]

  def from_string(string) do
    case FrontMatter.from_string(string) do
      {:ok, {meta, excerpt, body}} ->
        {
          :ok,
          %__MODULE__{
            title: meta.title,
            slug: meta.slug,
            date: meta.date,
            excerpt: excerpt,
            body: body,
            metadata: meta.extras,
          },
      }
      {:error, reason} -> {:error, reason}
    end
  end

  def put_excerpt_html(%__MODULE__{} = post, excerpt_html) do
    %__MODULE__{post | excerpt_html: excerpt_html}
  end

  def put_body_html(%__MODULE__{} = post, body_html) do
    %__MODULE__{post | body_html: body_html}
  end
end
