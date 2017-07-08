defmodule MinerAdmin.Api.Router do
  use HaveAPI.Builder

  version "1.0" do
    auth_chain []
    resources [
      MinerAdmin.Api.Node,
    ]
  end

  mount "/"
end
