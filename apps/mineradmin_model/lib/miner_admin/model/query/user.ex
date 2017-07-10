defmodule MinerAdmin.Model.Query.User do
  alias MinerAdmin.Model

  @repo Model.Repo
  @schema Model.Schema.User

  def count, do: @repo.aggregate(@schema, :count, :id)

  def all, do: @repo.all(@schema)

  def get(id), do: @repo.get(@schema, id)

  def get_by(params), do: @repo.get_by(@schema, params)
end
