defmodule Nabo.CompilerTest do
  use ExUnit.Case, async: true

  defmodule IncompetentFrontParser do
    @behaviour Nabo.Parser

    def parse(_data, _options) do
      {:ok, %Nabo.Metadata{
        title: "Incompetent Title",
        slug: "incompetent-slug",
        published_at: DateTime.from_naive!(~N[2017-01-01 00:00:00], "Etc/UTC"),
        draft?: false
      }}
    end
  end

  defmodule NegateParser do
    @behaviour Nabo.Parser

    def parse(string, _options) do
      parsed =
        string
        |> String.replace("This is", "This IS NOT")
        |> String.trim()

      {:ok, parsed}
    end
  end

  test "compile/2 with default parsers" do
    raw_post = """
    {"title":"Title","slug":"slug","published_at":"2017-01-01T01:02:03Z","draft":true}
    ---
    This is the _excerpt_.
    ---
    This is the **BODY**.
    """

    assert {:ok, post} = compile(raw_post, [])
    assert post.title == "Title"
    assert post.slug == "slug"
    assert post.published_at == DateTime.from_naive!(~N[2017-01-01 01:02:03], "Etc/UTC")
    assert post.excerpt == "This is the _excerpt_."
    assert post.excerpt_html == "<p>This is the <em>excerpt</em>.</p>\n"
    assert post.body == "This is the **BODY**.\n"
    assert post.body_html == "<p>This is the <strong>BODY</strong>.</p>\n"
  end

  test "compile/2 with custom split pattern" do
    raw_post = """
    {"title":"Title","slug":"slug","published_at":"2017-01-01T01:02:03Z","draft":true}
    <<----->>
    This is the _excerpt_.
    <<----->>
    This is the **BODY**.
    """

    assert {:ok, post} = compile(raw_post, [split_pattern: "<<----->>"])
    assert post.title == "Title"
    assert post.slug == "slug"
    assert post.published_at == DateTime.from_naive!(~N[2017-01-01 01:02:03], "Etc/UTC")
    assert post.excerpt == "\nThis is the _excerpt_.\n"
    assert post.excerpt_html == "<p>This is the <em>excerpt</em>.</p>\n"
    assert post.body == "\nThis is the **BODY**.\n"
    assert post.body_html == "<p>This is the <strong>BODY</strong>.</p>\n"
  end

  test "compile/2 with custom parsers" do
    raw_post = """
    {"title":"Title","slug":"slug","published_at":"2017-01-01T01:02:03Z","draft":true}
    ---
    This is the _excerpt_.
    ---
    This is the **BODY**.
    """

    options = [
      metadata_parser: {IncompetentFrontParser, []},
      excerpt_parser: {NegateParser, []},
      body_parser: {NegateParser, []}
    ]

    assert {:ok, post} = compile(raw_post, options)
    assert post.title == "Incompetent Title"
    assert post.slug == "incompetent-slug"
    assert post.published_at == DateTime.from_naive!(~N[2017-01-01 00:00:00], "Etc/UTC")
    assert post.excerpt == "This is the _excerpt_."
    assert post.excerpt_html == "This IS NOT the _excerpt_."
    assert post.body == "This is the **BODY**.\n"
    assert post.body_html == "This IS NOT the **BODY**."
  end

  defp compile(data, options) do
    Nabo.Compiler.compile(data, Nabo.Compiler.Options.new(options))
  end
end
