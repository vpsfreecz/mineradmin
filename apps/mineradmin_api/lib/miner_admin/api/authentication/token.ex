defmodule MinerAdmin.Api.Authentication.Token do
  use HaveAPI.Authentication.Token
  alias MinerAdmin.Model.Query

  def find_user_by_credentials(_conn, username, password) do
    authenticate(Query.User.get_by(login: username), password)
  end

  # TODO: regenerate token when unique constraint stops the save
  def save_token(_conn, user, token, lifetime, interval) do
    case Query.AuthToken.create(user, token, String.to_atom(lifetime), interval) do
      {:ok, t} ->
        {:ok, t.valid_to}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def find_user_by_token(_conn, token_str) do
    t = Query.AuthToken.find(token_str)

    if t do
      if t.lifetime == :renewable_auto do
        do_renew(t)

      else
        used(t)
      end

      t.user
    end
  end

  def renew_token(_conn, user, token_str) do
    case Query.AuthToken.find(user, token_str) do
      nil ->
        {:error, "token not found"}

      t ->
        {:ok, do_renew(t)}
    end
  end

  def revoke_token(_conn, user, token_str) do
    case Query.AuthToken.find(user, token_str) do
      nil ->
        {:error, "token not found"}

      t ->
        do_revoke(t)
        :ok
    end
  end

  defp authenticate(nil, _password), do: nil

  defp authenticate(user, password) do
    if user.password == password do
      user

    else
      :halt
    end
  end

  defp do_renew(token), do: Query.AuthToken.renew(token)

  defp do_revoke(token), do: Query.AuthToken.revoke(token)

  defp used(token), do: Query.AuthToken.update_used(token)
end
