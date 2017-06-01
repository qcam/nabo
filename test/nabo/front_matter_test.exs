defmodule Nabo.FrontMatterTest do
  use ExUnit.Case, async: true

  test "from_string/1" do
    string =
      ~s(
         {"title":"Hello","slug":"hello","date":"2017-01-01"}
         ---
         Welcome to your first Nabo post
         ---
         This is the content of your first Nabo post
       )
    assert({:ok, {%Nabo.Metadata{}, excerpt, body}} = Nabo.FrontMatter.from_string(string))
    assert(excerpt == "Welcome to your first Nabo post")
    assert(body == "This is the content of your first Nabo post")

    string =
      ~s(
         {"title":"Hello","slug":"hello","date":"2017-01-01"}
         ---
         This is the content of your first Nabo post
       )
    assert({:ok, {%Nabo.Metadata{}, "", body}} = Nabo.FrontMatter.from_string(string))
    assert(body == "This is the content of your first Nabo post")

    string = ~s({"title":"Hello","slug":"hello","date":"2017-01-01"})
    error_message = "Got wrong front matter format #{string}"
    assert({:error, ^error_message} = Nabo.FrontMatter.from_string(string))
  end
end
