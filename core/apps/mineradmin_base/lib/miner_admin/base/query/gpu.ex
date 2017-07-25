defmodule MinerAdmin.Base.Query.Gpu do
  use MinerAdmin.Base.Query

  def count(user), do: @repo.aggregate(query_for(user), :count, :id)

  def all(user) do
    from(gpu in query_for(user), preload: [:user, :node])
    |> @repo.all()
  end

  def get(id, user) do
    query_for(user)
    |> @repo.get(id)
    |> @repo.preload([:user, :node])
  end

  def create(params) do
    %@schema{}
    |> @schema.create_changeset(params)
    |> @repo.insert()
  end

  def delete(gpu), do: @repo.delete(gpu)

  defp query_for(user) do
    q = from(gpu in @schema, [])

    if Base.User.admin?(user) do
      q

    else
      from(gpu in q, where: gpu.user_id == ^user.id)
    end
  end
end
