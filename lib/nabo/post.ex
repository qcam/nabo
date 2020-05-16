defmodule Nabo.Post do
  @moduledoc """
  A struct that represents a post.

  This struct represents a post with its metadata, excerpt and post body, returned by
  `Nabo.Repo`.

  ## Format

  Post should be in this format:

      metadata (JSON, mandatory)
      ---
      post excerpt (Markdown, optional)
      ---
      post body (Markdown, mandatory)

  For example:

      {
        "title": "Hello World",
        "slug": "hello-world",
        "published_at": "2017-01-01T00:00:00Z"
      }
      ---
      Welcome to my blog!
      ---
      ### Hello there!

      This is the first post in my blog.

  Post excerpt is optional, so if you prefer not to have any excerpt, leave it blank or
  exclude it from your post.

      {
        "title": "Hello World",
        "slug": "hello-world",
        "published_at": "2017-01-01T00:00:00Z"
      }
      ---
      ### Hello there!

      This is the first post in my blog.

  """

  alias Nabo.Metadata

  defstruct [
    :title,
    :slug,
    :published_at,
    :draft?,
    :excerpt,
    :excerpt_html,
    :body,
    :body_html,
    :metadata,
    :reading_time
  ]

  @type slug() :: String.t()

  @type t() :: %__MODULE__{
    body: String.t,
    body_html: String.t,
    published_at: DateTime.t,
    draft?: boolean,
    reading_time: Float.t,
    excerpt: String.t,
    excerpt_html: String.t,
    metadata: Map.t,
    slug: slug(),
    title: String.t,
  }

  @doc false

  def new(metadata, excerpt, parsed_excerpt, body, parsed_body) do
    %__MODULE__{}
    |> enrich_metadata(metadata)
    |> enrich_excerpt(excerpt, parsed_excerpt)
    |> enrich_body(body, parsed_body)
    |> enrich_reading_time(compute_reading_time(body))
  end

  defp enrich_metadata(%__MODULE__{} = post, %Metadata{} = metadata) do
    post
    |> Map.put(:title, metadata.title)
    |> Map.put(:slug, metadata.slug)
    |> Map.put(:published_at, metadata.published_at)
    |> Map.put(:draft?, metadata.draft?)
    |> Map.put(:metadata, metadata.extras)
  end

  defp enrich_excerpt(%__MODULE__{} = post, raw_excerpt, parsed_excerpt) do
    post
    |> Map.put(:excerpt, raw_excerpt)
    |> Map.put(:excerpt_html, parsed_excerpt)
  end

  defp enrich_body(%__MODULE__{} = post, raw_body, parsed_body) do
    post
    |> Map.put(:body, raw_body)
    |> Map.put(:body_html, parsed_body)
  end

  defp enrich_reading_time(%__MODULE__{} = post, reading_time) do
    post
    |> Map.put(:reading_time, reading_time)
  end

  defp compute_reading_time(string, words_per_minute \\ 275) do
    string
    |> String.split(" ")
    |> Enum.count()
    |> Kernel./(words_per_minute)
    |> Float.round(2)
  end
end
