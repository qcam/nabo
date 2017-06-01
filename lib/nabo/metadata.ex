defmodule Nabo.Metadata do
  defstruct [:slug, :title, :date, :extras]

  def from_string(meta_string) do
    case Poison.decode(meta_string) do
      {:ok, metadata} ->
        title = Map.fetch!(metadata, "title")
        slug = Map.fetch!(metadata, "slug")
        date = Map.fetch!(metadata, "date")

        {
          :ok,
          %__MODULE__{
            title: title,
            slug: slug,
            date: date,
            extras: metadata,
          },
        }
      {:error, reason} ->
        {:error, "Error when parse metadata: #{Exception.message(reason)}"}
    end
  end
end
