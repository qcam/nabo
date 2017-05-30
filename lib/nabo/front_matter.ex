defmodule Nabo.FrontMatter do
  alias Nabo.Metadata

  def from_string(string) when is_binary(string) do
    string
    |> split_parts()
    |> parse_parts()
  end

  defp parse_parts([meta_string, excerpt, body]) do
    case Metadata.from_string(meta_string) do
      {:ok, metadata} -> {:ok, {metadata, excerpt, body}}
      {:error, reason} -> {:error, reason}
    end
  end
  defp parse_parts([meta_string, body]) do
    parse_parts([meta_string, "", body])
  end
  defp parse_parts(_parts), do: {:error, "Failed to parse front matter"}

  defp split_parts(string) do
    split_pattern = ~r/[\s\r\n]---[\s\r\n]/s

    string
    |> String.trim_leading()
    |> String.split(split_pattern, parts: 3)
  end
end
