defmodule Nabo.Parser.Front do
  @moduledoc false

  @behaviour Nabo.Parser

  alias Nabo.Metadata

  def parse(data, options) do
    case Jason.decode(data, options) do
      {:ok, json} ->
        with {:ok, title} <- build_title(json),
             {:ok, slug} <- build_slug(json),
             {:ok, published_at} <- build_published_at(json),
             {:ok, draft?} <- build_draft(json) do
          metadata = %Metadata{
            title: title,
            slug: slug,
            published_at: published_at,
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

  defp build_published_at(json) do
    case Map.fetch(json, "published_at") do
      :error ->
        {:error, "\"published_at\" has to be set"}

      {:ok, published_at} ->
        case DateTime.from_iso8601(published_at) do
          {:ok, published_at, _} ->
            {:ok, published_at}

          {:error, _reason} ->
            {:error, "\"published_at\" has to be in ISO-8601 format, got: #{inspect(published_at)}"}
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
