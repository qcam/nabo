defmodule Nabo.FrontMatter do
  alias Nabo.Metadata

  def from_string(string) when is_binary(string) do
    string
    |> split_parts()
    |> parse_parts()
  end

  defp parse_parts([meta_string, excerpt, body]) do
    trimmed_excerpt = String.trim(excerpt)
    trimmed_body = String.trim(body)
    case Metadata.from_string(meta_string) do
      {:ok, metadata} -> {:ok, {metadata, trimmed_excerpt, trimmed_body}}
      {:error, reason} -> {:error, reason}
    end
  end
  defp parse_parts([meta_string, body]) do
    parse_parts([meta_string, "", body])
  end
  defp parse_parts(parts), do: {:error, "Got wrong front matter format #{parts}"}

  defp split_parts(string) do
    split_pattern = ~r/[\s\r\n]---[\s\r\n]/s

    string
    |> String.trim_leading()
    |> String.split(split_pattern, parts: 3)
  end
end
