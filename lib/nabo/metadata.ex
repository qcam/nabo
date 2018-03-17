defmodule Nabo.Metadata do
  @moduledoc """
  A struct that represents post metadata.

  Represents metadata that specified in the top of the post.

  ## Format

  Metadata should be in JSON, and must have `title`, `slug`, and `date` set.

      {
        "title": "Nabo Post",
        "slug": "First Nabo post",
        "datetime": "2017-01-01T00:00:00Z"
      }

  You can have your own customized metadata and they will be accessible in `extras`.

      content = ~s(
      {
        "title": "Nabo Post",
        "slug": "First Nabo post",
        "datetime": "2017-01-01T00:00:00Z",
        "tags": ["foo", "bar"]
      }
      )
      {:ok, post} = Nabo.Post.from_string(content)
      post.metadata["tags"]

  """

  require Logger

  @typep t() :: __MODULE__.t()
  defstruct [:slug, :title, :datetime, :draft?, :extras]

  @doc false
  def from_string(meta_string) do
    case Jason.decode(meta_string) do
      {:ok, metadata} ->
        with {:ok, title} <- Map.fetch(metadata, "title"),
             {:ok, slug} <- Map.fetch(metadata, "slug"),
             draft? <- Map.get(metadata, "draft", false),
             datetime <- try_parse_datetime(metadata) do
          {
            :ok,
            %__MODULE__{
              title: title,
              slug: slug,
              datetime: datetime,
              draft?: draft?,
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

  @doc false
  defp try_parse_datetime(%{"date" => date} = _metadata) do
    Logger.warn("'date' will be deprecated in the next versions of Nabo, use 'datetime' instead")
    date = Date.from_iso8601!(date)
    {:ok, naive_datetime} = NaiveDateTime.new(date, ~T[00:00:00])
    DateTime.from_naive!(naive_datetime, "Etc/UTC")
  end
  defp try_parse_datetime(%{"datetime" => datetime} = _metadata) do
    {:ok, datetime, _} = DateTime.from_iso8601(datetime)
    datetime
  end
end
