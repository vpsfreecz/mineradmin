defmodule MinerAdmin.Api do
  @doc """
  Replace Ecto associations with values accepted by HaveAPI as output parameters.
  """
  def resourcify(list, associations) when is_list(list) do
    Enum.map(list, &(resourcify(&1, associations)))
  end

  def resourcify(struct, associations) when is_map(struct) do
    Enum.reduce(
      associations,
      struct,
      fn assoc, acc ->
        %{acc | assoc => assoc_to_resource(Map.fetch!(struct, :"#{assoc}_id"))}
      end
    )
  end

  @ doc """
  Convert HaveAPI resource input parameters into fields understood by Ecto.
  """
  def associatify(data, associations) when is_map(data) do
    Enum.reduce(
      associations,
      data,
      fn assoc, acc ->
        resource_to_assoc(acc, assoc)
      end
    )
  end

  def assoc_to_resource(nil), do: nil
  def assoc_to_resource(id), do: [id]

  def resource_to_assoc(data, assoc) do
    if Map.has_key?(data, assoc) do
      data = Map.put(data, :"#{assoc}_id", Map.fetch!(data, assoc))
      Map.delete(data, assoc)

    else
      data
    end
  end

  @doc """
  Format errors from Ecto changeset into form understood by HaveAPI.
  """
  def format_errors(changeset, msg \\ nil, opts \\ []) do
    opts = Keyword.put(opts, :errors, Enum.map(
      changeset.errors, fn {k, {msg, _opts}} -> {k, [msg]} end
    ) |> Map.new)

    {
      :error,
      msg || "Validation failed",
      opts,
    }
  end
end
