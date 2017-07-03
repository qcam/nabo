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
        "date": "2017-01-01"
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
        "date": "2017-01-01"
      }
      ---
      ### Hello there!

      This is the first post in my blog.

  """

  alias Nabo.FrontMatter

  defstruct [:title, :slug, :date, :draft?, :excerpt, :excerpt_html, :body, :body_html, :metadata, :reading_time]

  @type t :: %__MODULE__{
    body: String.t,
    body_html: String.t,
    date: Date.t,
    draft?: boolean,
    reading_time: Float.t,
    excerpt: String.t,
    excerpt_html: String.t,
    metadata: Map.t,
    slug: String.t,
    title: String.t,
  }

  @doc """
  Builds struct from markdown content.

  ## Example

      string = ~s(
        {
          "title": "Hello World",
          "slug": "hello-world",
          "date": "2017-01-01"
        }
        ---
        Welcome to my blog!
        ---
        ### Hello there!

        This is the first post in my blog.
      )
      {:ok, post} = Nabo.Post.from(string)
  """
  @spec from_string(string :: String.t) :: {:ok, Nabo.Post.t} | {:error, any}
  def from_string(string) do
    case FrontMatter.from_string(string) do
      {:ok, {meta, excerpt, body}} ->
        reading_time = compute_reading_time(body)

        {
          :ok,
          %__MODULE__{
            title: meta.title,
            slug: meta.slug,
            date: meta.date,
            draft?: meta.draft?,
            reading_time: reading_time,
            excerpt: excerpt,
            body: body,
            metadata: meta.extras,
          },
      }
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Puts parsed excerpt content into struct.
  """
  @spec put_excerpt_html(post :: __MODULE__.t, excerpt_html :: String.t) :: Nabo.Post.t
  def put_excerpt_html(%__MODULE__{} = post, excerpt_html) do
    %__MODULE__{post | excerpt_html: excerpt_html}
  end

  @doc """
  Puts parsed body content into struct.
  """
  @spec put_body_html(post :: __MODULE__.t, body_html :: String.t) :: Nabo.Post.t
  def put_body_html(%__MODULE__{} = post, body_html) do
    %__MODULE__{post | body_html: body_html}
  end

  @doc """
  Computes reading time of the given post body string
  """
  @spec compute_reading_time(body :: String.t) :: Float.t
  def compute_reading_time(body) when is_binary(body) do
    body
    |> String.split(" ")
    |> Enum.count
    |> Kernel./(275)
    |> Float.round(2)
  end
end
