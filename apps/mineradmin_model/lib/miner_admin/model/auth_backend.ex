defmodule MinerAdmin.Model.AuthBackend do
  alias MinerAdmin.Model

  @callback authenticate(
    pid_or_opts :: map | pid,
    user :: map,
    password :: String.t
  ) :: :ok | :incorrect_password | :not_found | {:error, String.t}

  def authenticate(nil, user, password) do
    apply(
      Model.AuthBackend.Default,
      :authenticate,
      [%{}, user, password]
    )
  end

  def authenticate(backend, user, password) do
    Model.AuthBackend.Wrapper.authenticate(backend, user, password)
  end

  def via_tuple(backend) do
    {:via, Registry, {Model.Registry, {:auth_backend, backend.id}}}
  end
end
