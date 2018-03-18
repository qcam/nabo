defmodule Nabo.Parser.MarkdownTest do
  use ExUnit.Case, async: true

  import Nabo.Parser.Markdown, only: [parse: 2]

  test "parse/2 without argument" do
    markdown = "This is **Markdown**"

    assert {:ok, parsed_body} = parse(markdown, [])
    assert parsed_body == "<p>This is <strong>Markdown</strong></p>\n"
  end

  test "parse/2 with Earmark option" do
    markdown = "This is \"Markdown\""

    assert {:ok, parsed_body} = parse(markdown, %Earmark.Options{smartypants: true})
    assert parsed_body == "<p>This is “Markdown”</p>\n"
  end
end
