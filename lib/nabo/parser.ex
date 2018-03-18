defmodule Nabo.Parser do
  @callback parse(data :: binary, options :: any) ::
              {:ok, parsed :: any} :: {:error, reason :: any}
end
