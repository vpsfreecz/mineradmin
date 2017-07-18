defmodule MinerAdmin.Api.Authentication.Basic do
  use HaveAPI.Authentication.Basic
  alias MinerAdmin.Model

  def find_user(conn, username, password) do
    case Model.User.authenticate(username, password) do
      {:ok, user} ->
        Model.UserSession.one_time(conn, user, :basic)
        user

      :incorrect_password ->
        :halt

      :not_found ->
        nil

      {:error, _msg} ->
        :halt
    end
  end
end