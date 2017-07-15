defmodule MinerAdmin.Model.Query.Node do
  use MinerAdmin.Model.Query

  def count, do: @repo.aggregate(@schema, :count, :id)

  def all, do: @repo.all(@schema)

  def get(id), do: @repo.get(@schema, id)

  def create(params) do
    changeset = @schema.create_changeset(%Model.Schema.Node{}, params)
    @repo.insert(changeset)
  end

  def update(node, params) do
    changeset = @schema.update_changeset(node, params)
    @repo.update(changeset)
  end

  def delete(node), do: @repo.delete(node)
end
