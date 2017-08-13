defmodule Nabo.TestRepo do
  use Nabo.Repo, root: "test/fixtures/posts"
end

defmodule Nabo.CustomCompilerRepo do
  use Nabo.Repo,
      root: "test/fixtures/posts",
      compiler: {
        Nabo.Compilers.Markdown,
        markdown: %Earmark.Options{code_class_prefix: "foo-"}
      }
end

defmodule Nabo.EmptyTestRepo do
  use Nabo.Repo, root: "/empty"
end

defmodule Nabo.RepoTest do
  use ExUnit.Case, async: true

  test "get/1" do
    {:ok, datetime, 0} = DateTime.from_iso8601("2017-01-01T00:00:00Z")
    assert({:ok, post} = Nabo.TestRepo.get("valid-post"))
    expected = %Nabo.Post{
      title: "Valid Post",
      slug: "valid-post",
      datetime: datetime,
      draft?: false,
      reading_time: 0.04,
      body: "### Welcome!\n\nThis is your first blog post built with *Nabo blog engine*",
      body_html: "<h3>Welcome!</h3>\n<p>This is your first blog post built with <em>Nabo blog engine</em></p>\n",
      excerpt: "Welcome to your first Nabo Post",
      excerpt_html: "<p>Welcome to your first Nabo Post</p>\n",
      metadata: %{"datetime" => "2017-01-01T00:00:00Z", "slug" => "valid-post", "title" => "Valid Post"},
    }
    assert(expected == post)

    assert({:error, _} = Nabo.TestRepo.get("foo"))
  end

  test "get/1 with customized compiler" do
    {:ok, datetime, 0} = DateTime.from_iso8601("2017-01-02T00:00:00Z")
    assert({:ok, post} = Nabo.CustomCompilerRepo.get("post-with-code"))
    expected = %Nabo.Post{
      title: "Post with code",
      slug: "post-with-code",
      datetime: datetime,
      draft?: false,
      reading_time: 0.01,
      body: "```elixir\nIO.inspect(1 + 1)\n```",
      body_html: "<pre><code class=\"elixir foo-elixir\">IO.inspect(1 + 1)</code></pre>\n",
      excerpt: "",
      excerpt_html: "",
      metadata: %{"datetime" => "2017-01-02T00:00:00Z", "slug" => "post-with-code", "title" => "Post with code"},
    }
    assert(expected == post)
  end

  test "all/1" do
    {:ok, datetime, 0} = DateTime.from_iso8601("2017-01-01T00:00:00Z")
    posts = Nabo.TestRepo.all()
    expected = %Nabo.Post{
      title: "Valid Post",
      slug: "valid-post",
      datetime: datetime,
      draft?: false,
      reading_time: 0.04,
      body: "### Welcome!\n\nThis is your first blog post built with *Nabo blog engine*",
      body_html: "<h3>Welcome!</h3>\n<p>This is your first blog post built with <em>Nabo blog engine</em></p>\n",
      excerpt: "Welcome to your first Nabo Post",
      excerpt_html: "<p>Welcome to your first Nabo Post</p>\n",
      metadata: %{"datetime" => "2017-01-01T00:00:00Z", "slug" => "valid-post", "title" => "Valid Post"},
    }
    assert(Enum.member?(posts, expected))
  end

  test "all/1 with empty repo" do
    assert(Nabo.EmptyTestRepo.all() == [])
  end

  test "availables" do
    availables = Nabo.TestRepo.availables()
    assert(Enum.count(availables) == 5)
    assert(Enum.member?(availables, "valid-post"))
    assert(Enum.member?(availables, "valid-post-1"))
  end

  test "all_by_date" do
    posts = Nabo.TestRepo.all() |> Nabo.TestRepo.order_by_datetime()
    expected = ["draft-post", "post-with-code", "valid-post", "valid-post-1", "old-post"]
    assert(Enum.map(posts, & &1.slug) == expected)
  end
end
