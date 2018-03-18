defmodule Nabo.Parser.Markdown do
  @behaviour Nabo.Parser

  def parse(data, options) do
    case parse_markdown(data, options) do
      {:ok, html, _} ->
        {:ok, html}

      {:error, _html, error_messages} ->
        {:error, error_messages}
    end
  end

  defp parse_markdown(data, []), do: Earmark.as_html(data)
  defp parse_markdown(data, options), do: Earmark.as_html(data, options)
end
