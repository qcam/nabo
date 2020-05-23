ExUnit.start(capture_log: true)

defmodule Nabo.TestRepos.Default do
  use Nabo.Repo, root: "test/fixtures/posts", compiler: [log_level: :debug]
end

defmodule Nabo.TestRepos.Customized do
  use Nabo.Repo,
    root: "test/fixtures/posts",
    compiler: [
      log_level: :debug,
      body_parser: {
        Nabo.Parser.Markdown,
        %Earmark.Options{code_class_prefix: "nabo-"}
      }
    ]
end

defmodule Nabo.TestRepos.Empty do
  use Nabo.Repo, root: "/empty"
end
