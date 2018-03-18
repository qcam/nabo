defmodule Nabo.Parser.FrontTest do
  use ExUnit.Case, async: true

  import Nabo.Parser.Front, only: [parse: 2]

  test "parse/2 with successful case" do
    json = """
    {
      "title": "Title",
      "slug": "slug",
      "datetime": "2017-01-01T01:02:03Z",
      "draft": false,
      "categories": ["cat-1", "cat-2"]
    }
    """

    assert {:ok, metadata} = parse(json, [])
    assert metadata.title == "Title"
    assert metadata.slug == "slug"
    assert metadata.datetime == DateTime.from_naive!(~N[2017-01-01 01:02:03], "Etc/UTC")
    assert metadata.draft? == false
    assert %{"categories" => ["cat-1", "cat-2"]} = metadata.extras
  end

  test "parse/2 with title missing" do
    json = """
    {
      "slug": "slug",
      "datetime": "2017-01-01T01:02:03Z",
      "draft": false,
      "categories": ["cat-1", "cat-2"]
    }
    """

    assert {:error, reason} = parse(json, [])
    assert reason == "\"title\" has to be set"
  end

  test "parse/2 with slug missing" do
    json = """
    {
      "title": "Title",
      "datetime": "2017-01-01T01:02:03Z",
      "draft": false,
      "categories": ["cat-1", "cat-2"]
    }
    """

    assert {:error, reason} = parse(json, [])
    assert reason == "\"slug\" has to be set"
  end

  test "parse/2 with datetime missing" do
    json = """
    {
      "title": "Title",
      "slug": "slug",
      "draft": false,
      "categories": ["cat-1", "cat-2"]
    }
    """

    assert {:error, reason} = parse(json, [])
    assert reason == "\"datetime\" has to be set"
  end

  test "parse/2 with bad format datetime" do
    json = """
    {
      "title": "Title",
      "slug": "slug",
      "datetime": "Fri, 21 Nov 1997 09:55:06 -0600",
      "draft": false,
      "categories": ["cat-1", "cat-2"]
    }
    """

    assert {:error, reason} = parse(json, [])
    assert reason == "\"datetime\" has to be in ISO-8601 format, got: \"Fri, 21 Nov 1997 09:55:06 -0600\""
  end

  test "parse/2 with bad JSON" do
    json = """
    {
      "title": "Title",
      "slug": "slug",
      "datetime": "Fri, 21 Nov 1997 09:55:06 -0600",
      "draft": false,
    }
    """

    assert {:error, reason} = parse(json, [])
    assert %Jason.DecodeError{} = reason
  end
end
