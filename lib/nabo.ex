defmodule Nabo do
  use Application

  def start(_, _) do
    children = []

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
