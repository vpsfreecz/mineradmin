defmodule MinerAdmin.Model.AuthBackend.HaveAPI do
  use GenServer
  alias MinerAdmin.Model
  alias HaveAPI.Client

  @behaviour Model.AuthBackend

  # Client API
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def authenticate(pid, user, password) do
    GenServer.call(pid, {:authenticate, user, password}, 15_000)
  end

  def user_changeset(changeset, _type) do
    Ecto.Changeset.validate_change(changeset, :password, fn :password, pwd ->
      if pwd do
        [password: "cannot be set, password from the remote API is used instead"]
      else
        []
      end
    end)
  end

  # Server implementation
  def init(opts) do
    GenServer.cast(self(), :init)

    {:ok, {opts, nil}}
  end

  def handle_cast(:init, {opts, nil}) do
    api = Client.connect(opts["url"])

    {:noreply, {opts, api}}
  end

  def handle_call({:authenticate, user, password}, _from, {opts, api}) do
    case Client.authenticate(api, :token, username: user.login, password: password) do
      {:ok, tmp_api} ->
        Client.logout(tmp_api)
        {:reply, :ok, {opts, api}}

      {:error, _msg} ->
        {:reply, :incorrect_password, {opts, api}}
    end
  end
end
