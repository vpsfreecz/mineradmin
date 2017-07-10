defmodule MinerAdmin.Api.Authentication.Basic do
  use HaveAPI.Authentication.Basic
  alias MinerAdmin.Model

  def find_user(conn, username, password) do
    authenticate(Model.Query.User.get_by(login: username), password)
  end

  defp authenticate(nil, _password), do: nil

  defp authenticate(user, password) do
    if user.password == password do
      user

    else
      :halt
    end
  end
end
