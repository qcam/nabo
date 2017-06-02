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

      defp _find(_, name), do: nil

      def get(name) when is_binary(name) do
        if Enum.member?(availables(), name) do
          content = _find(:content, name)
          excerpt_html = _find(:excerpt_html, name)
          body_html = _find(:body_html, name)
          {:ok, post} = Post.from_string(content)
          {
            :ok,
            post
            |> Post.put_excerpt_html(excerpt_html)
            |> Post.put_body_html(body_html)
          }
        else
          {:error, "Could not find post #{name}. Availables: #{formatted_availables()}"}
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
          availables() |> Enum.map(& get!(&1))
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

    {post.slug, quote do
      @file unquote(path)
      @external_resource unquote(path)

      defp _find(unquote(:content), unquote(post.slug)) do
        unquote(content)
      end

      defp _find(unquote(:excerpt_html), unquote(post.slug)) do
        unquote(excerpt_html)
      end

      defp _find(unquote(:body_html), unquote(post.slug)) do
        unquote(body_html)
      end
    end}
  end
end
