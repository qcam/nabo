defmodule Nabo.Compilers.MarkdownTest do
  use ExUnit.Case, async: true

  test "from_string/1 with meta string" do
    string =
      ~s(
         {"title":"Hello","slug":"hello","datetime":"2017-01-01T00:00:00Z"}
         ---
         Welcome to your first Nabo post
         ---
         This is the content of your first Nabo post
       )
    Nabo.Compilers.Markdown.compile(string)
  end
end
