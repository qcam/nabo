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

  require Logger

  @doc false

  defmacro __using__(options) do
    quote bind_quoted: [options: options], unquote: true do
      root_path =
        options
        |> Keyword.fetch!(:root)
        |> Path.relative_to_cwd

      compiler_options = Keyword.get(options, :compiler, [])

      @root_path root_path
      @compiler_options compiler_options

      @before_compile unquote(__MODULE__)
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    compiler_options = Module.get_attribute(env.module, :compiler_options)
    root_path = Module.get_attribute(env.module, :root_path)
    pattern = "*"

    {posts_map, _compiled_errors} =
      root_path
      |> find_all(pattern)
      |> async_compile(env.module, compiler_options)
      |> build_posts_map()

    quote do
      defp posts_map() do
        unquote(posts_map)
      end

      def get(name) do
        case Map.fetch(posts_map(), name) do
          {:ok, post} ->
            {:ok, post}

          :error ->
            {:error, "cannot find post #{name}, availables: #{inspect(availables())}"}
        end
      end

      def get!(name) when is_binary(name) do
        case get(name) do
          {:ok, post} ->
            post

          {:error, reason} ->
            raise(reason)
        end
      end

      def all() do
        Map.values(posts_map())
      end

      def order_by_datetime(posts) do
        Enum.sort(posts, & DateTime.compare(&1.datetime, &2.datetime) == :gt)
      end

      def exclude_draft(posts) do
        Enum.filter(posts, & !&1.draft?)
      end

      def filter_published(posts, datetime \\ DateTime.utc_now) do
        Enum.filter(posts, & DateTime.compare(&1.datetime, datetime) == :lt)
      end

      def availables do
        Map.keys(posts_map())
      end
    end
  end

  defp build_posts_map(compiled_entries, map \\ %{}, errors \\ [])

  defp build_posts_map([{:ok, slug, post} | rest], map, errors) do
    build_posts_map(rest, Map.put(map, slug, post), errors)
  end

  defp build_posts_map([{:error, path, reason} | rest], map, errors) do
    build_posts_map(rest, map, [{path, reason} | errors])
  end

  defp build_posts_map([], map, errors) do
    {Macro.escape(map), errors}
  end

  defp async_compile(paths, repo_name, compiler_options) do
    paths
    |> Enum.map(&Task.async(fn -> compile(&1, repo_name, compiler_options) end))
    |> Enum.map(&Task.await(&1))
  end

  defp compile(path, repo_name, options) do
    path
    |> File.read!()
    |> Nabo.Compiler.compile(options)
    |> case do
      {:ok, slug, post} ->
        {:ok, slug, post}

      {:error, reason} ->
        log_level = Keyword.get(options, :log_level, :warn)
        maybe_log(log_level, "Unable to compile post #{path} in #{repo_name}, reason: #{reason}")

        {:error, path, reason}
    end
  end

  defp find_all(root, pattern) do
    root
    |> Path.join([pattern, ".md"])
    |> Path.wildcard()
  end

  defp maybe_log(false, _message), do: :ok
  defp maybe_log(level, message), do: Logger.log(level, message)

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
  Order posts by date.

  ## Example

      posts = MyRepo.all() |> MyRepo.order_by_date()

  """
  @callback order_by_date(posts :: [Nabo.Post.t]) :: [Nabo.Post.t]

  @doc """
  Exclude draft posts.

  ## Example

      posts = MyRepo.all() |> MyRepo.exclude_draft()

  """
  @callback exclude_draft(posts :: [Nabo.Post.t]) :: [Nabo.Post.t]

  @doc """
  Filter only posts published before a specified datetime.

  ## Example

      posts = MyRepo.all() |> MyRepo.filter_published()

  """
  @callback filter_published(posts :: [Nabo.Post.t], datetime :: DateTime.t) :: [Nabo.Post.t]

  @doc """
  Fetches all availables post names in the repo.

  ## Example

      availables = MyRepo.availables()

  """
  @callback availables() :: List.t
end
