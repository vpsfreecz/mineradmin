defmodule MinerAdmin.Model.Query.User do
  use MinerAdmin.Model.Query

  def count, do: @repo.aggregate(@schema, :count, :id)

  def all do
    from(u in @schema, preload: [:auth_backend])
    |> @repo.all()
  end

  def get(id) do
    @schema
    |> @repo.get(id)
    |> @repo.preload([:auth_backend])
  end

  def get_by(params) do
    @schema
    |> @repo.get_by(params)
    |> @repo.preload([:auth_backend])
  end

  def create(params) do
    %@schema{}
    |> @schema.create_changeset(params)
    |> @repo.insert()
  end

  def update(user, params) do
    user
    |> @schema.update_changeset(params)
    |> @repo.update()
  end

  def delete(user), do: @repo.delete(user)
end
