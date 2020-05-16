defmodule Nabo.Metadata do
  @moduledoc """
  A struct that represents post metadata.

  Represents metadata that specified in the top of the post.
  """

  @typep t() :: __MODULE__.t()

  defstruct [
    :slug,
    :title,
    :published_at,
    :draft?,
    :extras
  ]
end
