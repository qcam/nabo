defmodule Nabo.IntegrationTest do
  use ExUnit.Case, async: true

  alias Nabo.TestRepos

  test "get/1 with a short markdown" do
    assert post = TestRepos.Default.get("this-year-0202")

    assert post.title == "This year 02-02"
    assert post.slug == "this-year-0202"
    assert post.datetime == DateTime.from_naive!(~N[2017-02-02 00:00:00], "Etc/UTC")
    refute post.draft?
    assert post.excerpt == "This is the post for 02-02"
    assert post.excerpt_html == "<p>This is the post for 02-02</p>\n"
    assert post.body == "### Welcome!\n\nThis is your first blog post built with *Nabo blog engine*\n"
    assert post.body_html == "<h3>Welcome!</h3>\n<p>This is your first blog post built with <em>Nabo blog engine</em></p>\n"

    assert TestRepos.Default.get("something-that-does-not-exist") == nil
  end

  test "get/1 with a long markdown" do
    assert post = TestRepos.Default.get("this-year-0101")

    assert post.title == "This year 01-01"
    assert post.slug == "this-year-0101"
    assert post.datetime == DateTime.from_naive!(~N[2017-01-01 00:00:00], "Etc/UTC")
    refute post.draft?
    assert post.excerpt == "This is the post for 01-01"
    assert post.excerpt_html == "<p>This is the post for 01-01</p>\n"

    assert TestRepos.Default.get("something-that-does-not-exist") == nil
  end

  test "get/1 with customized compiler" do
    assert post = TestRepos.Customized.get("this-year-0303")

    assert post.body == "### Welcome!\n\n```elixir\na = 1\n```\n"
    assert post.body_html == "<h3>Welcome!</h3>\n<pre><code class=\"elixir nabo-elixir\">a = 1</code></pre>\n"
  end

  test "all/1" do
    assert posts = TestRepos.Default.all()
    assert Enum.count(posts) == 6
  end

  test "all/1 with empty repo" do
    assert TestRepos.Empty.all() == []
  end

  test "availables/0" do
    expected = ["draft-post", "last-year", "next-year", "this-year-0101", "this-year-0202", "this-year-0303"]
    assert TestRepos.Default.availables() == expected
  end
end
