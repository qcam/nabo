defmodule Nabo.RepoTest do
  use ExUnit.Case, async: true

  # test "availables" do
  #   availables = Nabo.TestRepo.availables()
  #   assert(Enum.count(availables) == 6)
  #   assert(Enum.member?(availables, "valid-post"))
  #   assert(Enum.member?(availables, "valid-post-1"))
  # end
  #
  # test "order_by_datetime" do
  #   posts = Nabo.TestRepo.all() |> Nabo.TestRepo.order_by_datetime()
  #   expected = ["future-post", "draft-post", "post-with-code", "valid-post", "valid-post-1", "old-post"]
  #   assert(Enum.map(posts, & &1.slug) == expected)
  # end
  #
  # test "exclude_draft" do
  #   posts = Nabo.TestRepo.all()
  #           |> Nabo.TestRepo.exclude_draft()
  #           |> Nabo.TestRepo.order_by_datetime()
  #   expected = ["future-post", "post-with-code", "valid-post", "valid-post-1", "old-post"]
  #   assert(Enum.map(posts, & &1.slug) == expected)
  # end
  #
  # test "filter_published" do
  #   {:ok, before, 0} = DateTime.from_iso8601("2017-12-31T00:00:00Z")
  #   posts = Nabo.TestRepo.all()
  #           |> Nabo.TestRepo.filter_published(before)
  #           |> Nabo.TestRepo.order_by_datetime()
  #   expected = ["draft-post", "post-with-code", "valid-post", "valid-post-1", "old-post"]
  #   assert(Enum.map(posts, & &1.slug) == expected)
  # end
  #
  # test "filter_published with default parameter" do
  #   now = DateTime.utc_now()
  #   posts = Nabo.TestRepo.all()
  #           |> Nabo.TestRepo.filter_published()
  #           |> Nabo.TestRepo.order_by_datetime()
  #   assert(Enum.all?(posts, & DateTime.compare(&1.datetime, now) == :lt))
  # end
end
