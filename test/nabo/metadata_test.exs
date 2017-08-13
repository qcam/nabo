defmodule Nabo.MetadataTest do
  use ExUnit.Case, async: true

  test "from_string/1 with meta string" do
    string = ~s({"title":"Hello","slug":"hello","datetime":"2017-01-01T00:00:00Z"})
    assert({:ok, metadata = %Nabo.Metadata{}} = Nabo.Metadata.from_string(string))
    {:ok, datetime, 0} = DateTime.from_iso8601("2017-01-01T00:00:00Z")
    expected = %Nabo.Metadata{
      title: "Hello",
      slug: "hello",
      datetime: datetime,
      draft?: false,
      extras: %{
        "title" => "Hello",
        "slug" => "hello",
        "datetime" => "2017-01-01T00:00:00Z",
      },
    }
    assert(expected == metadata)

    string = ~s({"title":"Hello","draft":true,"slug":"hello","datetime":"2017-01-01T00:00:00Z"})
    assert({:ok, metadata = %Nabo.Metadata{}} = Nabo.Metadata.from_string(string))
    {:ok, datetime, 0} = DateTime.from_iso8601("2017-01-01T00:00:00Z")
    expected = %Nabo.Metadata{
      title: "Hello",
      slug: "hello",
      datetime: datetime,
      draft?: true,
      extras: %{
        "title" => "Hello",
        "slug" => "hello",
        "datetime" => "2017-01-01T00:00:00Z",
        "draft" => true,
      },
    }
    assert(expected == metadata)

    string = ~s({"slug":"hello","datetime":"2017-01-01T00:00:00Z"})
    assert({:error, _} = Nabo.Metadata.from_string(string))

    string = ~s(invalid-json)
    assert({:error, "Got invalid json string invalid-json"} = Nabo.Metadata.from_string(string))
  end
end
