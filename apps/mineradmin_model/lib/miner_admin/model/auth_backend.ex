defmodule MinerAdmin.Model.AuthBackend do
  alias MinerAdmin.Model

  @callback authenticate(
    opts :: map,
    user :: map,
    password :: String.t
  ) :: :ok | :incorrect_password | :not_found

  def authenticate(nil, user, password) do
    apply(
      Model.AuthBackend.Default,
      :authenticate,
      [%{}, user, password]
    )
  end

  def authenticate(backend, user, password) do
    apply(
      Module.concat([backend.module]),
      :authenticate,
      [backend.opts, user, password]
    )
  end
end
