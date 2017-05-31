defmodule Nabo.Web.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/", do: send_resp(conn, 200, "Nabo OK")
  get "/:slug", do: send_resp(conn, 200, "Nabo OK #{slug}")
end
