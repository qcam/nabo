defmodule Nabo.Web.Template do
  require EEx

  EEx.function_from_file :def, :layout, "lib/nabo/web/layouts/main.eex", [:body]
  EEx.function_from_file :def, :posts, "lib/nabo/web/layouts/posts.eex", [:posts]
  EEx.function_from_file :def, :post, "lib/nabo/web/layouts/post.eex", [:post]
end
