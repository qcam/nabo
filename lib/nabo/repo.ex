defmodule Nabo.Repo do
  alias Nabo.Post

  defmacro __using__(options) do
    quote bind_quoted: [options: options], unquote: true do
      @root Keyword.fetch!(options, :root) |> Path.relative_to_cwd

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    root = Module.get_attribute(env.module, :root)
    pattern = "**/*"
    pairs = find_all(root, pattern)
            |> Enum.map(& compile(&1))
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
        {
          :ok,
          availables()
          |> Stream.map(& Task.async(fn -> get!(&1) end))
          |> Enum.map(&Task.await/1)
        }
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

  defp compile(path) do
    content = File.read!(path)
    {:ok, post} = Nabo.Post.from_string(content)
    excerpt_html = Earmark.as_html!(post.excerpt)
    body_html = Earmark.as_html!(post.body)
    compiled_body = post
                    |> Post.put_excerpt_html(excerpt_html)
                    |> Post.put_body_html(body_html)
                    |> Macro.escape

    {post.slug, quote do
      @file unquote(path)
      @external_resource unquote(path)

      defp _find(unquote(post.slug)) do
        unquote(compiled_body)
      end
    end}
  end
end
