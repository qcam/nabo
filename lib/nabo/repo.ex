defmodule Nabo.Repo do
  @moduledoc """
  Precompiles and provides interface to interact with your posts.

      defmodule MyRepo do
        use Nabo.Repo, root: "priv/posts"
      end

      posts = MyRepo.all
      {:ok, post} = MyRepo.get("foo")
      post = MyRepo.get!("foo")

  ## Compiler

  By default Nabo uses `Nabo.Compilers.Markdown` compiler.

  To customize compiler or compiler options, use `:compiler` option.

      defmodule MyRepo do
        use Nabo.Repo,
            root: "priv/posts",
            compiler: {
              Nabo.Compilers.Markdown,
              markdown: %Earmark.Options{smartypants: false}
            }
      end

  See `Nabo.Compiler` more more information of how to build your own compiler.
  """

  alias Nabo.Post

  @doc false
  defmacro __using__(options) do
    quote bind_quoted: [options: options], unquote: true do
      {{compiler, compiler_opts}, _} = Keyword.pop(options, :compiler, {Nabo.Compilers.Markdown, []})
      root = Keyword.fetch!(options, :root) |> Path.relative_to_cwd

      @root root
      @compiler compiler
      @compiler_opts compiler_opts

      @before_compile unquote(__MODULE__)
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    compiler = Module.get_attribute(env.module, :compiler)
    compiler_opts = Module.get_attribute(env.module, :compiler_opts)
    root = Module.get_attribute(env.module, :root)
    pattern = "**/*"
    pairs = find_all(root, pattern)
            |> Enum.map(& compile(compiler, &1, compiler_opts))
    names = Enum.map(pairs, &elem(&1, 0))
    codes = Enum.map(pairs, &elem(&1, 1))

    quote [generated: true] do
      unquote(codes)

      defp _find(name), do: nil

      def get(name) when is_binary(name) do
        case _find(name) do
          %Post{} = post -> {:ok, post}
          nil -> {:error, "Could not find post #{name}. Availables: #{formatted_availables()}"}
        end
      end

      def get!(name) when is_binary(name) do
        case get(name) do
          {:ok, post} -> post
          {:error, reason} -> raise(reason)
        end
      end

      def all do
        availables()
        |> Stream.map(& Task.async(fn -> get!(&1) end))
        |> Enum.map(&Task.await/1)
      end

      def order_by_datetime(posts) do
        Enum.sort(posts, & DateTime.compare(&1.datetime, &2.datetime) == :gt)
      end

      def availables do
        unquote(names)
      end

      defp formatted_availables() do
        availables() |> Enum.join(", ")
      end
    end
  end

  defp find_all(root, pattern) do
    root
    |> Path.join(pattern <> ".md")
    |> Path.wildcard()
  end

  defp compile(compiler, path, compiler_opts) do
    {identifier, compiled} = File.read!(path)
                             |> compiler.compile(compiler_opts)

    {identifier, quote do
      @file unquote(path)
      @external_resource unquote(path)

      defp _find(unquote(identifier)) do
        unquote(compiled)
      end
    end}
  end

  @doc """
  Finds a post by the given slug.

  ## Example

      {:ok, post} = MyRepo.get("my-slug")

  """
  @callback get(name :: String.t) :: {:ok, Nabo.Post.t} | {:error, any}

  @doc """
  Similar to `get/1` but raises error when no post was found.

  ## Example

      post = MyRepo.get!("my-slug")

  """
  @callback get!(name :: String.t) :: Nabo.Post.t

  @doc """
  Fetches all available posts in the repo.

  ## Example

      posts = MyRepo.all()

  """
  @callback all() :: [Nabo.Post.t]

  @doc """
  Order posts by date

  ## Example

      posts = MyRepo.all() |> MyRepo.order_by_date()

  """
  @callback order_by_date(posts :: [Nabo.Post.t]) :: [Nabo.Post.t]

  @doc """
  Fetches all availables post names in the repo.

  ## Example

      availables = MyRepo.availables()

  """
  @callback availables() :: List.t
end
