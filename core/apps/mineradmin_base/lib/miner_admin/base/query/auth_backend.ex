defmodule MinerAdmin.Base.Query.AuthBackend do
  use MinerAdmin.Base.Query

  def all(opts \\ []), do: @schema |> paginate(opts) |> @repo.all()

  def count, do: @repo.aggregate(@schema, :count, :id)

  def get(id), do: @repo.get(@schema, id)
end
