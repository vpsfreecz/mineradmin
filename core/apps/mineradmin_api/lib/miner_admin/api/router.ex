defmodule MinerAdmin.Api.Router do
  use HaveAPI.Builder
  alias MinerAdmin.Api

  version "1.0" do
    auth_chain [
      Api.Authentication.Basic,
      Api.Authentication.Token,
    ]

    resources [
      Api.AuthBackend,
      Api.User,
      Api.Node,
      Api.Gpu,
      Api.Program,
      Api.UserProgram,
    ]
  end

  mount "/"
end
