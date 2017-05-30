defmodule Nabo.Metadata do
  defstruct [:slug, :title, :date]

  def from_string(meta_string) do
    case Poison.decode(meta_string) do
      {:ok, metadata} ->
        with {:ok, date} <- Date.from_iso8601(metadata["date"]) do
          {
            :ok,
            %__MODULE__{
              title: metadata["title"],
              slug: metadata["slug"],
              date: date,
            },
          }
        else
          {:error, reason} ->
            {:error, "Error when parse metadata date: #{Exception.message(reason)}"}
        end
      {:error, reason} ->
        {:error, "Error when parse metadata: #{Exception.message(reason)}"}
    end
  end
end
