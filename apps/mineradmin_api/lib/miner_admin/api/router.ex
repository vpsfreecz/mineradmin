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
      Api.Node,
    ]
  end

  mount "/"
end
