defmodule Nabo.TestRepo do
  use Nabo.Repo, root: "test/fixtures/posts"
end

defmodule Nabo.EmptyTestRepo do
  use Nabo.Repo, root: "/empty"
end

defmodule Nabo.RepoTest do
  use ExUnit.Case, async: true

  test "get/1" do
    assert({:ok, post} = Nabo.TestRepo.get("valid-post"))
    expected = %Nabo.Post{
      title: "Valid Post",
      slug: "valid-post",
      date: ~D[2017-01-01],
      body: "### Welcome!\n\nThis is your first blog post built with *Nabo blog engine*",
      body_html: "<h3>Welcome!</h3>\n<p>This is your first blog post built with <em>Nabo blog engine</em></p>\n",
      excerpt: "Welcome to your first Nabo Post",
      excerpt_html: "<p>Welcome to your first Nabo Post</p>\n",
      metadata: %{"date" => "2017-01-01", "slug" => "valid-post", "title" => "Valid Post"},
    }
    assert(expected == post)

    assert({:error, _} = Nabo.TestRepo.get("foo"))
  end

  test "all/1" do
    assert({:ok, posts} = Nabo.TestRepo.all())
    expected = %Nabo.Post{
      title: "Valid Post",
      slug: "valid-post",
      date: ~D[2017-01-01],
      body: "### Welcome!\n\nThis is your first blog post built with *Nabo blog engine*",
      body_html: "<h3>Welcome!</h3>\n<p>This is your first blog post built with <em>Nabo blog engine</em></p>\n",
      excerpt: "Welcome to your first Nabo Post",
      excerpt_html: "<p>Welcome to your first Nabo Post</p>\n",
      metadata: %{"date" => "2017-01-01", "slug" => "valid-post", "title" => "Valid Post"},
    }
    assert(Enum.member?(posts, expected))
  end

  test "all/1 with empty repo" do
    assert({:ok, []} = Nabo.EmptyTestRepo.all())
  end

  test "availables" do
    availables = Nabo.TestRepo.availables()
    assert(Enum.count(availables) == 2)
    assert(Enum.member?(availables, "valid-post"))
    assert(Enum.member?(availables, "valid-post-1"))
  end
end
