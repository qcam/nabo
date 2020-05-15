defmodule Nabo.Parser do
  @moduledoc """
  The behaviour to implement a parser in Nabo. It requires a `parse/2` callback to be implemented.

  There are three kinds of parser for accordingly three components in a post: a front parser for metadata,
  an excerpt parser and finally a post body parser.

  By default Nabo uses JSON for post metadata and Markdown for excerpt and post body, but with these three parsers
  implemented, you can have these components in your most loved format.

  ## Example

  Given a raw post like this.

  ```
  title,slug,datetime,draft
  Nabo,nabo,"Monday, 15-Aug-2005 15:52:01 UTC",false
  ---
  This is a post body
  ---
  [heading]Heading 1[/heading]
  [b]bold[b]
  [i]italics[i]
  [url=https://www.wikipedia.org/]Wikipedia[/url]
  ```

  ### Implement a front Parser

  The `parse/2` function of a front parser has to return `{:ok, %Nabo.Metadata{}}`.

  ```
  defmodule MyFrontParser do
    @behaviour Nabo.Parser

    def parse(binary, options) do
      data = MyCSVParser.parse(binary, options)
      metadata = %Nabo.Metadata{
        title: data["title"],
        slug: data["slug"],
        datetime: data["datetime"],
        draft?: data["draft"]
      }

      {:ok, metadata}
    end
  end
  ```

  ### Implement an excerpt parser

  ```
  defmodule MyExcerptParser do
    def parse(binary, _options) do
      {:ok, binary}
    end
  end
  ```

  ### Implement a body parser

  ```
  defmodule MyBodyParser do
    def parse(binary, options) do
    {:ok, MyBBCodeParser.parse(binary, options)}
    end
  end
  ```

  Then everything is ready to be configured in the repo.

  ```
  defmodule MyRepo do
    use Nabo.Repo,
    root: "/path/to/posts",
    compiler: [
      front_parser: {MyFrontParser, []},
      excerpt_parser: {MyExcerptParser, []},
      body_parser: {MyBodyParser, []},
    ]
  end
  ```

  """

  @doc """
  Parses a input binary into the desired format.
  """

  @callback parse(data :: binary, options :: any) ::
              {:ok, parsed :: any} | {:error, reason :: any}
end
