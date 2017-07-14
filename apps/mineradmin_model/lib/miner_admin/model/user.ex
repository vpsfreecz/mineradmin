defmodule MinerAdmin.Model.User do
  alias MinerAdmin.Model
  alias MinerAdmin.Model.Query

  @spec authenticate(
    username :: String.t, password :: String.t
  ) :: {:ok, any} | :incorrect_password | :not_found

  def authenticate(username, password) do
    do_authenticate(Query.User.get_by(login: username), password)
  end

  defp do_authenticate(nil, _password), do: :not_found
  defp do_authenticate(user, password) do
    case Model.AuthBackend.authenticate(user.auth_backend, user, password) do
      :ok ->
        {:ok, user}

      other ->
        other
    end
  end

  # TODO: should return true/false and let controllers translate that to
  #   allow/deny
  def admin?(user) do
    if user.role == 0, do: :allow, else: :deny
  end
end
