defmodule MinerAdmin.Model.Query.AuthBackend do
  use MinerAdmin.Model.Query

  def all, do: @repo.all(@schema)

  def count, do: @repo.aggregate(@schema, :count, :id)

  def get(id), do: @repo.get(@schema, id)
end
