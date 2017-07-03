defmodule Nabo.PostTest do
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
    {:ok, date} = Date.new(2017, 1, 1)
    expected = %Nabo.Post{
      title: "Hello",
      slug: "hello",
      date: date,
      draft?: false,
      reading_time: 0.03,
      excerpt: "Welcome to your first Nabo post",
      body: "This is the content of your first Nabo post",
      metadata: %{
        "title" => "Hello",
        "slug" => "hello",
        "date" => "2017-01-01",
      }
    }
    assert({:ok, post} = Nabo.Post.from_string(string))
    assert(expected == post)
  end

  test "compute_reading_time/1" do
    post_body = String.pad_trailing("a", 1000, " a")
    string =
      ~s(
         {"title":"Hello","slug":"hello","date":"2017-01-01"}
         ---
         Welcome to your first Nabo post
         ---
         #{post_body}
       )
    expected = %Nabo.Post{
      title: "Hello",
      slug: "hello",
      date: ~D[2017-01-01],
      draft?: false,
      reading_time: 1.82,
      excerpt: "Welcome to your first Nabo post",
      body: String.trim(post_body),
      metadata: %{
        "title" => "Hello",
        "slug" => "hello",
        "date" => "2017-01-01",
      }
    }
    assert({:ok, post} = Nabo.Post.from_string(string))
    assert(expected == post)
  end
end
