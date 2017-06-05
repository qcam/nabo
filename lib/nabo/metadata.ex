defmodule Nabo.Metadata do
  @moduledoc """
  A struct that represents post metadata.

  Represents metadata that specified in the top of the post.

  ## Format

  Metadata should be in JSON, and must have `title`, `slug`, and `date` set.

      {
        "title": "Nabo Post",
        "slug": "First Nabo post",
        "date": "2017-01-01"
      }

  You can have your own customized metadata and they will be accessible in `extras`.

      content = ~s(
      {
        "title": "Nabo Post",
        "slug": "First Nabo post",
        "date": "2017-01-01",
        "tags": ["foo", "bar"]
      }
      )
      {:ok, post} = Nabo.Post.from_string(content)
      post.metadata["tags"]

  """

  @typep t() :: __MODULE__.t()
  defstruct [:slug, :title, :date, :extras]

  @doc false
  def from_string(meta_string) do
    case Poison.decode(meta_string) do
      {:ok, metadata} ->
        with {:ok, title} <- Map.fetch(metadata, "title"),
             {:ok, slug} <- Map.fetch(metadata, "slug"),
             {:ok, date} <- Map.fetch(metadata, "date"),
             date <- Date.from_iso8601!(date) do
          {
            :ok,
            %__MODULE__{
              title: title,
              slug: slug,
              date: date,
              extras: metadata,
            },
          }
        else
          :error ->
            {:error, "Failed to parse metadata: Did you have title, slug, and date set?"}
        end
      {:error, _} ->
        {:error, "Got invalid json string #{meta_string}"}
    end
  end
end
