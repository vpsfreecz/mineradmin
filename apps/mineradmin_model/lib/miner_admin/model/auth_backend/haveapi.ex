defmodule MinerAdmin.Model.AuthBackend.HaveAPI do
  alias MinerAdmin.Model
  alias HaveAPI.Client

  @behaviour Model.AuthBackend

  def authenticate(opts, user, password) do
    # TODO: move the client into a separate process, so that it does not have
    # to be initialized on each login request.
    api = Client.connect(opts["url"])

    case Client.authenticate(api, :token, username: user.login, password: password) do
      {:ok, api} ->
        Client.logout(api)
        :ok

      {:error, _msg} ->
        :incorrect_password
    end
  end
end
