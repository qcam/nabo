defmodule Nabo.Repo do
  @moduledoc """
  Precompiles and provides interface to interact with your posts.

      defmodule MyRepo do
        use Nabo.Repo, root: "priv/posts"
      end

      posts = MyRepo.all
      {:ok, post} = MyRepo.get("foo")
      post = MyRepo.get!("foo")

  Can be configured with:

  ```
  defmodule MyRepo do
    use Nabo.Repo,
        root: "priv/posts",
        compiler: [
          split_pattern: "<<--------->>",
          log_level: :warn,
          front_parser: {MyJSONParser, []},
          excerpt_parser: {MyExcerptParser, []},
          body_parser: {Nabo.Parser.Markdown, %Earmark.Options{smartypants: false}}
        ]
  end
  ```

  * `:root` - the path to posts.
  * `:compiler` - the compiler options, includes of four sub-options. See `Nabo.Parser` for instructions of how to implement a parser.
    * `:split_pattern` - the delimeter that separates front-matter, excerpt and post body. This will be passed
      as the second argument in `String.split/3`.
    * `:log_level` - the error log level in compile time, use `false` to disable logging completely. Defaults to `:warn`.
    * `:front_parser` - the options for parsing front matter, in `{parser_module, parser_options}` format.
      Parser options will be passed to `parse/2` function in parser module. Defaults to `{Nabo.Parser.Front, []}`
    * `:excerpt_parser` - the options for parsing post excerpt, in `{parser_module, parser_options}` format.
      Parser options will be passed to `parse/2` function in parser module. Defaults to `{Nabo.Parser.Markdown, []}`
    * `:body_parser` - the options for parsing post body, in `{parser_module, parser_options}` format.
      Parser options will be passed to `parse/2` function in parser module. Defaults to `{Nabo.Parser.Markdown, []}`

  """

  require Logger

  @doc false

  defmacro __using__(options) do
    quote location: :keep do
      options = unquote(options)

      root_path =
        options
        |> Keyword.fetch!(:root)
        |> Path.relative_to_cwd()

      compiler_options =
        options
        |> Keyword.get(:compiler, [])
        |> Nabo.Compiler.Options.new()

      @root_path root_path
      @compiler_options compiler_options

      def __options__(), do: unquote(options)

      @before_compile unquote(__MODULE__)
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    root_path = Module.get_attribute(env.module, :root_path)
    compiler_options = Module.get_attribute(env.module, :compiler_options)

    post_paths = Path.wildcard(root_path <> "/*.md")

    posts = post_paths |> compile_async(compiler_options) |> Macro.escape()

    quote bind_quoted: [posts: posts, paths: post_paths] do
      for path <- paths, do: @external_resource(path)

      @posts posts

      def all(), do: @posts

      slugs = Enum.map(@posts, & &1.slug)
      def availables(), do: unquote(slugs)

      for %{slug: slug} = post <- @posts do
        def get(unquote(slug)) do
          unquote(Macro.escape(post))
        end
      end

      def get(slug), do: nil

      def get!(slug) when is_binary(slug) do
        case get(slug) do
          nil ->
            raise "could not find post with #{inspect(slug)}, availables: #{inspect(availables())}"

          post ->
            post
        end
      end

      def order_by_datetime(posts) do
        Enum.sort(posts, &(DateTime.compare(&1.published_at, &2.published_at) == :gt))
      end

      def exclude_draft(posts) do
        Enum.reject(posts, & &1.draft?)
      end

      def filter_published(posts, published_at \\ DateTime.utc_now()) do
        Enum.filter(posts, &(DateTime.compare(&1.published_at, published_at) == :lt))
      end
    end
  end

  defp compile_async(paths, compiler_options) do
    paths
    |> Task.async_stream(&compile(&1, compiler_options))
    |> Enum.flat_map(fn
      {:ok, compiled} -> List.wrap(compiled)
      {:error, _} -> []
    end)
  end

  defp compile(path, options) do
    log_level = options.log_level
    content = File.read!(path)

    case Nabo.Compiler.compile(content, options) do
      {:ok, post} ->
        post

      {:error, reason} ->
        Logger.log(log_level, ["Could not compile ", inspect(path), " due to: ", reason])

        nil
    end
  end

  @doc """
  Finds a post by the given slug.

  ## Example

      MyRepo.get("my-slug")

  """
  @callback get(slug :: Nabo.Post.slug()) :: Nabo.Post.t() | nil

  @doc """
  Similar to `get/1` but raises error when no post is found.

  ## Example

      post = MyRepo.get!("my-slug")

  """
  @callback get!(slug :: Nabo.Post.slug()) :: Nabo.Post.t()

  @doc """
  Fetches all available posts in the repo.

  ## Example

      posts = MyRepo.all()

  """
  @callback all() :: [Nabo.Post.t()]

  @doc """
  Order posts by date.

  ## Example

      posts = MyRepo.all() |> MyRepo.order_by_date()

  """
  @callback order_by_date(posts :: [Nabo.Post.t()]) :: [Nabo.Post.t()]

  @doc """
  Exclude draft posts.

  ## Example

      posts = MyRepo.all() |> MyRepo.exclude_draft()

  """
  @callback exclude_draft(posts :: [Nabo.Post.t()]) :: [Nabo.Post.t()]

  @doc """
  Filter only posts published before a specified datetime.

  ## Example

      posts = MyRepo.all() |> MyRepo.filter_published()

  """
  @callback filter_published(posts :: [Nabo.Post.t()], published_at :: DateTime.t()) :: [
              Nabo.Post.t()
            ]

  @doc """
  Fetches all availables post names in the repo.

  ## Example

      availables = MyRepo.availables()

  """
  @callback availables() :: [Nabo.Post.slug()]
end
