defmodule Nabo.Compiler do
  @moduledoc """
  A behaviour with callback to compile raw post into macros.

  ## Example

      defmodule Nabo.MyCompiler do
        def compile(content) do
          post = MyPost.parse_from_string(content)

          {post.date
        end
      end

  """
  @doc """
  Compiles a raw post into Macro.

  Note that the first element in the return result is the identifier of the post, which is
  used by the repo to find the post.
  """
  @callback compile(content :: String.t, options :: Keyword.t) :: {identifier :: String.t, compiled :: Macro.t}
end
