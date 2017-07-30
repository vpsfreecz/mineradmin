defmodule MinerAdmin.Base.User do
  alias MinerAdmin.Base
  alias MinerAdmin.Base.Query

  @spec authenticate(
    username :: String.t, password :: String.t
  ) :: {:ok, any} | :incorrect_password | :not_found | {:error, String.t}

  def authenticate(username, password) do
    do_authenticate(Query.User.get_by(login: username), password)
  end

  defp do_authenticate(nil, _password), do: :not_found
  defp do_authenticate(user, password) do
    case Base.AuthBackend.authenticate(user.auth_backend, user, password) do
      :ok ->
        {:ok, user}

      other ->
        other
    end
  end

  def admin?(user), do: user.role == 0
end
