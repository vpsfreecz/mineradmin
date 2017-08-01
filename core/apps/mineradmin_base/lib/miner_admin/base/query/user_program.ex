defmodule MinerAdmin.Base.Query.UserProgram do
  use MinerAdmin.Base.Query

  def count(user), do: @repo.aggregate(query_for(user), :count, :id)

  def all(user) do
    from(up in query_for(user), preload: [:user, :program, :node])
    |> @repo.all()
  end

  def get(id, user) do
    query_for(user)
    |> @repo.get(id)
    |> @repo.preload([:user, :program, :node])
  end

  def create(params) do
    ret = %@schema{}
    |> @schema.create_changeset(params)
    |> @repo.insert()

    case ret do
      {:ok, user_prog} ->
        {:ok, @repo.preload(user_prog, [:user, :program, :node])}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def update(user_prog, params) do
    user_prog
    |> @schema.update_changeset(params)
    |> @repo.update()
  end

  def delete(user_prog), do: @repo.delete(user_prog)

  def gpus(user_prog) do
    @repo.preload(user_prog, [:gpus]).gpus
  end

  def gpus_count(id) do
    from(
      up in @schema,
      join: g in assoc(up, :gpus),
      select: g.id,
      where: up.id == ^id,
    ) |> @repo.aggregate(:count, :id)
  end

  def get_gpu(user_prog, gpu_id) do
    from(
      g in Schema.Gpu,
      join: up in assoc(g, :user_programs),
      where: up.id == ^user_prog.id,
      where: g.id == ^gpu_id
    ) |> @repo.one
  end

  def add_gpu(user_prog, gpu) do
    user_prog
    |> @repo.preload([:gpus])
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:gpus, [gpu])
    |> @repo.update()
  end

  def remove_gpu(user_prog, gpu) do
    {1, _return} = from(
      up_g in "user_program_gpus",
      where: up_g.user_program_id == ^user_prog.id,
      where: up_g.gpu_id == ^gpu.id
    ) |> @repo.delete_all()
  end

  def activate(user_prog, bool) do
    user_prog
    |> @schema.active_changeset(%{active: bool})
    |> @repo.update()
  end

  def on_node(node_name) do
    {name, domain} = Base.Node.name(node_name)

    from(
      up in @schema,
      join: n in assoc(up, :node),
      where: n.name == ^name and n.domain == ^domain,
      preload: [:program, :gpus, :node]
    ) |> @repo.all
  end

  defp query_for(user) do
    q = from(up in @schema, [])

    if Base.User.admin?(user) do
      q

    else
      from(up in q, where: up.user_id == ^user.id)
    end
  end
end
