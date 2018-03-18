defmodule Nabo.Parser.Front do
  @behaviour Nabo.Parser

  alias Nabo.Metadata

  def parse(data, options) do
    case Jason.decode(data, options) do
      {:ok, json} ->
        with {:ok, title} <- build_title(json),
             {:ok, slug} <- build_slug(json),
             {:ok, datetime} <- build_datetime(json),
             {:ok, draft?} <- build_draft(json) do
          metadata = %Metadata{
            title: title,
            slug: slug,
            datetime: datetime,
            draft?: draft?,
            extras: json
          }

          {:ok, metadata}
        else
          {:error, reason} -> {:error, reason}
        end

      {:error, _} = error -> error
    end
  end

  defp build_title(json) do
    case Map.fetch(json, "title") do
      {:ok, title} -> {:ok, title}
      :error -> {:error, "\"title\" has to be set"}
    end
  end

  defp build_slug(json) do
    case Map.fetch(json, "slug") do
      {:ok, slug} -> {:ok, slug}
      :error -> {:error, "\"slug\" has to be set"}
    end
  end

  defp build_datetime(json) do
    case Map.fetch(json, "datetime") do
      :error ->
        {:error, "\"datetime\" has to be set"}

      {:ok, datetime} ->
        case DateTime.from_iso8601(datetime) do
          {:ok, datetime, _} ->
            {:ok, datetime}

          {:error, _reason} ->
            {:error, "\"datetime\" has to be in ISO-8601 format, got: #{inspect(datetime)}"}
        end
    end
  end

  defp build_draft(json) do
    case Map.get(json, "draft", false) do
      draft? when is_boolean(draft?) ->
        {:ok, draft?}

      other ->
        {:error, "\"draft\" has to be a boolean, got: #{inspect(other)}"}
    end
  end
end
