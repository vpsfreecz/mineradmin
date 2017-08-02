defmodule MinerAdmin.Base.Query.UserProgramLog do
  use MinerAdmin.Base.Query

  def all(user_prog) do
    user_prog
    |> query()
    |> @repo.all()
  end

  def count(user_prog) do
    user_prog
    |> query()
    |> @repo.aggregate(:count, :id)
  end

  def get(user_prog, id) do
    from(
      l in query(user_prog),
      where: l.id == ^id
    ) |> @repo.one()
  end

  def create(params) do
    %@schema{}
    |> @schema.changeset(params)
    |> @repo.insert()
  end

  defp query(user_prog) do
    from(
      l in @schema,
      join: up in assoc(l, :user_program),
      where: up.id == ^user_prog.id,
      order_by: [desc: :inserted_at, desc: :id]
    )
  end
end
