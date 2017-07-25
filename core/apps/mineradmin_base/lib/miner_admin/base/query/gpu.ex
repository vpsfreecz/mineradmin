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

  def update(gpu, params) do
    gpu
    |> @schema.update_changeset(params)
    |> @repo.update()
  end

  def delete(gpu), do: @repo.delete(gpu)

  @doc """
  Update info about GPUs identified by node name and UUID. `gpus` is a list
  of tuples in the following format: `{uuid, changes}`, where `changes` is
  a map of attribute changes.
  """
  def update_by_uuids(gpus, node_name) when is_list(gpus) do
    uuids = Enum.map(gpus, fn {uuid, _changes} -> uuid end)
    existing = all_by_uuids(node_name, uuids)

    for gpu <- existing, {uuid, changes} <- gpus, gpu.uuid == uuid do
      {:ok, _gpu} = Query.Gpu.update(gpu, changes)
    end
  end

  defp all_by_uuids(node_name, uuids) do
    {name, domain} = Base.Node.name(node_name)

    from(
      gpu in @schema,
      join: n in Schema.Node, on: gpu.node_id == n.id,
      where: n.name == ^name,
      where: n.domain == ^domain,
      where: gpu.uuid in ^uuids
    ) |> @repo.all()
  end

  defp query_for(user) do
    q = from(gpu in @schema, [])

    if Base.User.admin?(user) do
      q

    else
      from(gpu in q, where: gpu.user_id == ^user.id)
    end
  end
end
