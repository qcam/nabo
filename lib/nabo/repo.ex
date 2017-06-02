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

    pairs = for path <- find_all(root, pattern) do
      compile(path, root)
    end

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
          {:error, "Could not find post #{name}. Availables: #{availables()}"}
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
    end
  end

  defp find_all(root, pattern) do
    root
    |> Path.join(pattern <> ".md")
    |> Path.wildcard()
  end

  defp path_to_name(path, root) do
    path
    |> Path.rootname()
    |> Path.relative_to(root)
  end

  defp compile(path, root) do
    name = path_to_name(path, root)
    content = File.read!(path)
    {:ok, post} = Nabo.Post.from_string(content)
    excerpt_html = Earmark.as_html!(post.excerpt)
    body_html = Earmark.as_html!(post.body)

    {name, quote do
      @file unquote(path)
      @external_resource unquote(path)

      defp _find(unquote(:content), unquote(name)) do
        unquote(content)
      end

      defp _find(unquote(:excerpt_html), unquote(name)) do
        unquote(excerpt_html)
      end

      defp _find(unquote(:body_html), unquote(name)) do
        unquote(body_html)
      end
    end}
  end
end
