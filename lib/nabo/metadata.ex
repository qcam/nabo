defmodule Nabo.Metadata do
  @moduledoc """
  A struct that represents post metadata.

  Represents metadata that specified in the top of the post.

  ## Format

  Metadata should be in JSON, and must have `title`, `slug`, and `datetime` set.

      {
        "title": "Nabo Post",
        "slug": "First Nabo post",
        "datetime": "2017-01-01T00:00:00Z"
      }
  """

  @typep t() :: __MODULE__.t()

  defstruct [
    :slug,
    :title,
    :datetime,
    :draft?,
    :extras
  ]
end
