defmodule MinerAdmin.Model.Query.AuthToken do
  import Ecto.Query, only: [from: 2]
  alias MinerAdmin.Model

  @repo Model.Repo
  @schema Model.Schema.AuthToken

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

  def renew(token) do
    valid_to = Timex.add(DateTime.utc_now, Timex.Duration.from_seconds(token.interval))

    from(
      t in @schema,
      where: t.id == ^token.id,
      update: [
        set: [valid_to: ^valid_to],
        inc: [use_count: 1],
    ]) |> @repo.update_all([])

    valid_to
  end

  def revoke(token) do
    @repo.delete(token)
  end

  def update_used(token) do
    from(
      t in @schema,
      where: t.id == ^token.id,
      update: [inc: [use_count: 1]]
    ) |> @repo.update_all([])
  end

  defp valid_to(:permanent, _interval), do: nil
  defp valid_to(_lifetime, interval) do
    Timex.add(DateTime.utc_now, Timex.Duration.from_seconds(interval))
  end
end
