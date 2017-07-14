defmodule MinerAdmin.Model.AuthBackend.Default do
  alias MinerAdmin.Model

  @behaviour Model.AuthBackend

  def authenticate(opts, user, password) do
    if user.password == password do
      :ok

    else
      :incorrect_password
    end
  end
end
