defmodule MinerAdmin.Base.Query.AuthBackend do
  use MinerAdmin.Base.Query

  def all, do: @repo.all(@schema)

  def count, do: @repo.aggregate(@schema, :count, :id)

  def get(id), do: @repo.get(@schema, id)
end
