# Nabo

Dead simple blog engine

[Documentation](https://hexdocs.pm/nabo/).

Nabo is designed to be a simple, fast, extendable blog engine. You can integrate Nabo to any components
in your application like Phoenix, Plug.

It does not include routers or html generators, but focuses on doing one thing and
does it well: manages your blog posts.

## Installation

```elixir
def deps do
  [{:nabo, "~> 0.0.1"}]
end
```

To start using Nabo, first you need to create your own repo. Use this mix task:

```
mix nabo.gen.repo MyApp.Repo
```

Nabo assumes your posts are in `priv/posts`, if they are not, you can change the
`:root` option in the generated repo.

```elixir
defmodule MyWeb.Repo do
  use Nabo.Repo, root: "path/to/posts"
end
```

Nabo provides `nabo.gen.post` mix task to generate posts.

```
mix nabo.gen.post my-first-blog-post
```

All posts in Nabo should follow this format.

```md
{
  "title": "Welcome to Nabo",
  "slug": "welcome",
  "date": "2017-01-01"
}
---
This is the excerpt of the post in markdown
---
This is the *body* of the post in markdown
```

### Phoenix integration

```elixir
defmodule MyWeb.PostController do
  use MyWeb.Web, :controller

  def index(conn, _params) do
    {:ok, posts} = MyWeb.Repo.all()
    render conn, "index.html", posts: posts
  end

  def show(conn, %{"slug" => slug}) do
    {:ok, post} = MyWeb.Repo.get(slug)
    #or post = MyWeb.Repo.get!(slug) This will raise if no post was found
    render conn, "show.html", post: post
  end
end
```

Then in your template.

```elixir
# index.html.eex
<div class="posts">
  <%= for post <- posts do %>
  <div class="post">
    <h3><%= post.title %></h3>
    <div class="excerpt"><%= post.excerpt_html %></div>
  </div>
  <% end %>
</div>
```

```elixir
# show.html.eex
<div class="post">
  <h1><%= post.title %></h1>
  <div class="body"><%= post.body %></div>
</div>
```

### Plug integration

```elixir
defmodule MyWeb.Router do
  use Plug.Router
  import Plug.Conn

  plug :match
  plug :dispatch

  get "/posts" do
    {:ok, posts} = MyWeb.Repo.all()

    body =
      posts
      |> Enum.map(& %{title: &1.title, slug: &1.slug})
      |> Poison.encode!

    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(200, body)
    |> halt()
  end

  get "/posts/:slug" do
    case MyWeb.Repo.get(slug) do
      {:ok, %Nabo.Post{title: title, body_html: body_html}} ->
        body = %{title: title, body: body_html} |> Poison.encode!
        conn
        |> put_resp_header("content-type", "application/json;charset=utf-8")
        |> send_resp(200, body)
        |> halt()
      {:error, reason} -> send_resp(conn, 404, reason) |> halt()
    end
  end
end
```

## Q&A

> How does Nabo work?

Nabo pre-compiles all posts in the configured repo and delivers it when you ask.
That's it, no magic.

> Why this post engine does not support generating static html like Jekyll and
> such?

Nabo is not meant to replace Jekyll since Jekyll has done their job really well
(trust me the previous version of my blog was built with Jekyll). But Nabo takes
another approach and is designed to integrate with other components in your
application. If you want to build a blog with more controllable functions like
comments or traffic count, then Nabo might fit your needs. If you need a minimal
version of static html blog that can play well with Github page, then Jekyll
would probably be your choice.

> Why Nabo does not support template, router, controller or server?

As mentioned, Nabo is designed to be simple and integrate-able with other
components in your application so it does not presume your needs.

If you want routing or templating, you can easily integrate Nabo to Phoenix
or Plug.

## Development and issue report

If you have any issues or ideas, feel free to write to https://github.com/qcam/nabo/issues.
