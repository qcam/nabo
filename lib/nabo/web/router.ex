defmodule Nabo.Web.Router do
  use Plug.Router

  alias Nabo.Web.{Template}

  plug :match
  plug :dispatch

  get "/", private: %{repo: Nabo.Web.Repo} do
    repo = conn.private.repo

    posts = repo.all()

    posts_body = Template.posts(posts)
    html = Template.layout(posts_body)

    send_resp(conn, 200, html)
  end

  get "/:slug", private: %{repo: Nabo.Web.Repo} do
    repo = conn.private.repo

    post = repo.get!(slug)

    post_body = Template.post(post)
    html = Template.layout(post_body)

    send_resp(conn, 200, html)
  end
end
