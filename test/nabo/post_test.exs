defmodule Nabo.PostTest do
  use ExUnit.Case, async: true

  test "from_string/1" do
    string =
      ~s(
         {"title":"Hello","slug":"hello","datetime":"2017-01-01T00:00:00Z"}
         ---
         Welcome to your first Nabo post
         ---
         This is the content of your first Nabo post
       )
    {:ok, datetime, 0} = DateTime.from_iso8601("2017-01-01T00:00:00Z")
    expected = %Nabo.Post{
      title: "Hello",
      slug: "hello",
      datetime: datetime,
      draft?: false,
      reading_time: 0.03,
      excerpt: "Welcome to your first Nabo post",
      body: "This is the content of your first Nabo post",
      metadata: %{
        "title" => "Hello",
        "slug" => "hello",
        "datetime" => "2017-01-01T00:00:00Z",
      }
    }
    assert({:ok, post} = Nabo.Post.from_string(string))
    assert(expected == post)
  end

  test "compute_reading_time/1" do
    {:ok, datetime, 0} = DateTime.from_iso8601("2017-01-01T00:00:00Z")
    post_body = String.pad_trailing("a", 1000, " a")
    string =
      ~s(
         {"title":"Hello","slug":"hello","datetime":"2017-01-01T00:00:00Z"}
         ---
         Welcome to your first Nabo post
         ---
         #{post_body}
       )
    expected = %Nabo.Post{
      title: "Hello",
      slug: "hello",
      datetime: datetime,
      draft?: false,
      reading_time: 1.82,
      excerpt: "Welcome to your first Nabo post",
      body: String.trim(post_body),
      metadata: %{
        "title" => "Hello",
        "slug" => "hello",
        "datetime" => "2017-01-01T00:00:00Z",
      }
    }
    assert({:ok, post} = Nabo.Post.from_string(string))
    assert(expected == post)
  end
end
