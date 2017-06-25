defmodule Nabo.MetadataTest do
  use ExUnit.Case, async: true

  test "from_string/1 with meta string" do
    string = ~s({"title":"Hello","slug":"hello","date":"2017-01-01"})
    assert({:ok, metadata = %Nabo.Metadata{}} = Nabo.Metadata.from_string(string))
    {:ok, date} = Date.new(2017, 1, 1)
    expected = %Nabo.Metadata{
      title: "Hello",
      slug: "hello",
      date: date,
      draft?: false,
      extras: %{
        "title" => "Hello",
        "slug" => "hello",
        "date" => "2017-01-01",
      },
    }
    assert(expected == metadata)

    string = ~s({"title":"Hello","draft":true,"slug":"hello","date":"2017-01-01"})
    assert({:ok, metadata = %Nabo.Metadata{}} = Nabo.Metadata.from_string(string))
    {:ok, date} = Date.new(2017, 1, 1)
    expected = %Nabo.Metadata{
      title: "Hello",
      slug: "hello",
      date: date,
      draft?: true,
      extras: %{
        "title" => "Hello",
        "slug" => "hello",
        "date" => "2017-01-01",
        "draft" => true,
      },
    }
    assert(expected == metadata)

    string = ~s({"slug":"hello","date":"2017-01-01"})
    assert({:error, _} = Nabo.Metadata.from_string(string))

    string = ~s(invalid-json)
    assert({:error, "Got invalid json string invalid-json"} = Nabo.Metadata.from_string(string))
  end
end
