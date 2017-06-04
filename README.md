# Nabo

Dead simple blog engine

## Why use Nabo?

Nabo is designed to be a really fast, simple and extendable blog engine. You could
integrate Nabo in Phoenix, Plug.Router or any kind of plugs you want.

## Why is it fast?

All markdown posts are pre-compiled, there will not be any parsing done in
runtime so it should be deadly fast.

## Installation

```elixir
def deps do
  [{:nabo, "~> 0.0.1"}]
end
```

To start using Nabo, first you need to create your own repo. Let's assume all
your blog posts were kept in `priv/_posts`.

```elixir
defmodule MyWeb.Repo do
  use Nabo.Repo, root: "priv/_posts"
end
```

All blog posts used in Nabo should follow this format.

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

Then in your template

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

### Plug.Router integration

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

> Why this post engine does not support generating static html like Jekyll and
> such?

Personally I think Elixir is fast enough to handle this. And in fact all
markdown files are parsed in compile time, so there's no extra parsing in
runtime. If you are looking for a blog engine that generates static HTML so you
can use it on Github or so, then you already have the answer, go for the awesome
*Jekyll*

> Why this post engine does not support template/router/controller and stuff like that?

As mentioned, Nabo is designed to be simple and easily integrate-able. Phoenix
and Plug has already done a really good job and let's not re-invent the wheel.

## Development and issue report

If you have any issues or ideas, feel free to write to https://github.com/qcam/nabo/issues.
