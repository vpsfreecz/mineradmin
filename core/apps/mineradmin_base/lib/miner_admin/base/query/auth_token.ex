defmodule MinerAdmin.Base.Query.AuthToken do
  use MinerAdmin.Base.Query

  def create(user, token_str, lifetime, interval) do
    Ecto.build_assoc(user, :auth_tokens)
    |> @schema.create_changeset(%{
         token: token_str,
         lifetime: lifetime,
         interval: interval,
         valid_to: valid_to(lifetime, interval)
       })
    |> @repo.insert()
  end

  def find(token_str) do
    from(
      t in @schema,
      where: t.token == ^token_str,
      where: t.lifetime == "permanent" or t.valid_to > fragment("NOW() AT TIME ZONE 'UTC'"),
      limit: 1,
      preload: [:user]
    ) |> @repo.one
  end

  def find(user, token_str) do
    from(
      t in @schema,
      where: t.token == ^token_str,
      where: t.user_id == ^user.id,
      where: t.lifetime == "permanent" or t.valid_to > fragment("NOW() AT TIME ZONE 'UTC'"),
      limit: 1,
      preload: [:user]
    ) |> @repo.one
  end

  def extend(token) do
    valid_to = Timex.add(DateTime.utc_now, Timex.Duration.from_seconds(token.interval))

    {:ok, _} = token
      |> @schema.extend_changeset(%{valid_to: valid_to})
      |> @repo.update

    valid_to
  end

  def revoke(id) when is_integer(id) do
    from(
      t in @schema,
      where: t.id == ^id
    ) |> @repo.delete_all()
  end

  def revoke(token) do
    @repo.delete(token)
  end

  defp valid_to(:permanent, _interval), do: nil
  defp valid_to(_lifetime, interval) do
    Timex.add(DateTime.utc_now, Timex.Duration.from_seconds(interval))
  end
end
