defmodule Nabo.Metadata do
  defstruct [:slug, :title, :date, :extras]

  def from_string(meta_string) do
    case Poison.decode(meta_string) do
      {:ok, metadata} ->
        with {:ok, title} <- Map.fetch(metadata, "title"),
             {:ok, slug} <- Map.fetch(metadata, "slug"),
             {:ok, date} <- Map.fetch(metadata, "date"),
             date <- Date.from_iso8601!(date) do
          {
            :ok,
            %__MODULE__{
              title: title,
              slug: slug,
              date: date,
              extras: metadata,
            },
          }
        else
          :error ->
            {:error, "Failed to parse metadata: Did you have title, slug, and date set?"}
        end
      {:error, reason} ->
        {:error, "Got invalid json string #{meta_string}"}
    end
  end
end
