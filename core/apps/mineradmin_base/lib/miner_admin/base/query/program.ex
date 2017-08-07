defmodule MinerAdmin.Base.Query.Program do
  use MinerAdmin.Base.Query

  def count, do: @repo.aggregate(@schema, :count, :id)

  def all(opts \\ []), do: @schema |> paginate(opts) |> @repo.all()

  def get(id), do: @repo.get(@schema, id)

  def create(params) do
    %@schema{}
    |> @schema.create_changeset(params)
    |> @repo.insert()
  end

  def update(prog, params) do
    prog
    |> @schema.update_changeset(params)
    |> @repo.update()
  end

  def delete(prog), do: @repo.delete(prog)
end
