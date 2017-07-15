defmodule MinerAdmin.Api.Authentication.Token do
  use HaveAPI.Authentication.Token
  alias MinerAdmin.Model
  alias MinerAdmin.Model.Query

  def find_user_by_credentials(_conn, username, password) do
    case Model.User.authenticate(username, password) do
      {:ok, user} ->
        user

      :incorrect_password ->
        nil

      :not_found ->
        nil

      {:error, _msg} ->
        nil
    end
  end

  # TODO: regenerate token when unique constraint stops the save
  def save_token(conn, user, token, lifetime, interval) do
    case Query.AuthToken.create(user, token, String.to_atom(lifetime), interval) do
      {:ok, t} ->
        {:ok, _session} = Model.UserSession.open(conn, user, token: t)
        {:ok, t.valid_to}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def find_user_by_token(_conn, token_str) do
    case Model.UserSession.find(token: token_str) do
      nil ->
        nil

      session ->
        Model.UserSession.continue(session)
        session.user
    end
  end

  def renew_token(_conn, _user, token_str) do
    case Model.UserSession.find(token: token_str) do
      nil ->
        {:error, "token not found"}

      session ->
        {:ok, Model.UserSession.extend(session)}
    end
  end

  def revoke_token(_conn, _user, token_str) do
    case Model.UserSession.find(token: token_str) do
      nil ->
        {:error, "token not found"}

      session ->
        Model.UserSession.close(session)
        :ok
    end
  end
end
