defmodule MinerAdmin.Base.Query.UserSession do
  use MinerAdmin.Base.Query

  def find([token: token]) do
    from(
      s in @schema,
      where: s.auth_token_id == ^token.id,
      preload: [:user, :auth_token]
    ) |> @repo.one
  end

  def create(params) do
    {:ok, session} = %@schema{}
      |> @schema.create_changeset(params)
      |> @repo.insert
    {:ok, @repo.preload(session, [:user, :auth_token])}
  end

  def one_time(params) do
    {:ok, session} = %@schema{}
      |> @schema.create_changeset(params)
      |> @schema.update_changeset(%{closed_at: DateTime.utc_now, request_count: 1})
      |> @repo.insert

    @repo.preload(session, [:user])
  end

  def update(session, params) do
    session
    |> @schema.update_changeset(params)
    |> @repo.update
  end

  def close(%@schema{auth_method: "token"} = session, params) do
    {:ok, _session} = @repo.transaction(fn ->
      token_id = session.auth_token_id

      {:ok, _session} = update(session, Map.merge(params, %{
        auth_token_id: nil
      }))

      Base.Query.AuthToken.revoke(token_id)
    end)
  end

  def active_sessions do
    from(s in @schema, where: is_nil(s.closed_at), preload: [:user, :auth_token])
    |> @repo.all
  end
end
