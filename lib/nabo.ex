defmodule Nabo do
  @moduledoc """
  Nabo is a simple, fast blog engine written in Elixir.

  Nabo is designed to be integrate-able to other components in your application like
  Phoenix or Plug. It does not include stuff like routing or html generating,
  but only focuses on one thing and does it well: manages your blog posts.

  ## Posts

  Post is the heart of Nabo and is represented as `Nabo.Post` struct.

  You can keep your blog posts in any directories you like in the source code,
  but all posts should follow this format.

      metadata (JSON, mandatory)
      ---
      post excerpt (Markdown, optional)
      ---
      post body (JSON, mandatory)

  ### Example

      {
        "title": "First Nabo post",
        "slug": "first-post",
        "date": "2017-01-01"
      }
      ---
      This is my first blog post created with Nabo.
      ---
      ### Section 1

      My first blog post created with Nabo.

      ### Section 2

      ...

  See `Nabo.Post` for more information.

  ## Repo

  To access your blog posts, you need to create a repo.

      defmodule MyRepo do
        use Nabo.Repo, root: "priv/posts"
      end

  To get all posts.

      {:ok, posts} = MyRepo.all()

  To get a post by its slug.

      {:ok, post} = MyRepo.get("first-post")

  See `Nabo.Repo` for more information.
  """
end
