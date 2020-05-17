defmodule Mix.Tasks.Nabo.Gen.PostTest do
  use ExUnit.Case, async: true

  import Mix.Tasks.Nabo.Gen.Post

  import ExUnit.CaptureIO

  setup :clean_up_tmp

  defp clean_up_tmp(_) do
    "tmp/nabo"
    |> Path.relative_to_cwd()
    |> File.rm_rf()

    :ok
  end

  defmodule DummyRepo do
    use Nabo.Repo, root: "tmp/nabo/dummy-repo"
  end

  describe "run/1" do
    test "generates file" do
      repo_name = Macro.to_string(DummyRepo)

      string =
        capture_io(fn ->
          run(["foo", "--repo=#{repo_name}"])
        end)

      assert string =~ ~r(creating.*tmp/nabo/dummy-repo/)
    end

    test "expects valid repo" do
      assert_raise(Mix.Error, "Could not load DoesNotExist due to :nofile", fn ->
        run(["foo", "--repo=DoesNotExist"])
      end)
    end
  end
end
