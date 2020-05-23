defmodule Nabo.Compiler do
  @moduledoc false

  alias Nabo.Post

  defmodule Options do
    @moduledoc false

    defstruct metadata_parser: {Nabo.Parser.Front, []},
              excerpt_parser: {Nabo.Parser.Markdown, []},
              body_parser: {Nabo.Parser.Markdown, []},
              split_pattern: ~r/[\s\r\n]---[\s\r\n]/s,
              log_level: :warn

    def new(options) when is_list(options) do
      options = struct!(__MODULE__, options)

      ensure_parsers(options)

      options
    end

    defp ensure_parsers(options) do
      options
      |> Map.take([:metadata_parser, :excerpt_parser, :body_parser])
      |> Map.values()
      |> Enum.each(&ensure_parser/1)
    end

    defp ensure_parser({module, _}) do
      case Code.ensure_compiled(module) do
        {:module, ^module} ->
          if function_exported?(module, :parse, 2) do
            module
          else
            raise ArgumentError, "Expect parser to be a Nabo.Parser"
          end

        {:error, reason} ->
          raise ArgumentError,
                "Configured parser #{inspect(module)} is not available due to #{inspect(reason)}"
      end
    end
  end

  def compile(data, options) do
    %Options{
      metadata_parser: metadata_parser,
      excerpt_parser: excerpt_parser,
      body_parser: body_parser,
      split_pattern: split_pattern
    } = options

    with {:ok, {front, excerpt, body}} <- split_parts(data, split_pattern),
         {:ok, metadata} <- parse(front, metadata_parser),
         {:ok, parsed_excerpt} <- parse(excerpt, excerpt_parser),
         {:ok, parsed_body} <- parse(body, body_parser) do
      {:ok, Post.new(metadata, excerpt, parsed_excerpt, body, parsed_body)}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp split_parts(raw_post, pattern) do
    parts =
      raw_post
      |> String.trim_leading()
      |> String.split(pattern, parts: 3)

    case parts do
      [front, body] ->
        {:ok, {front, "", body}}

      [front, excerpt, body] ->
        {:ok, {front, excerpt, body}}

      _ ->
        {:error, "cannot split post with the configured pattern #{inspect(pattern)}"}
    end
  end

  defp parse(data, {parser, parser_options}) do
    apply(parser, :parse, [data, parser_options])
  end
end
