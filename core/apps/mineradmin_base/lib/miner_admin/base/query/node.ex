defmodule MinerAdmin.Base.Query.Node do
  use MinerAdmin.Base.Query

  def count, do: @repo.aggregate(@schema, :count, :id)

  def all(opts \\ []), do: @schema |> paginate(opts) |> @repo.all()

  def get(id), do: @repo.get(@schema, id)

  def create(params) do
    changeset = @schema.create_changeset(%@schema{}, params)
    @repo.insert(changeset)
  end

  def update(node, params) do
    changeset = @schema.update_changeset(node, params)
    @repo.update(changeset)
  end

  def delete(node), do: @repo.delete(node)
end
