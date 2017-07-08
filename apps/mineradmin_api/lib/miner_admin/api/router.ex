defmodule MinerAdmin.Api.Router do
  use HaveAPI.Builder

  version "1.0" do
    auth_chain []
    resources []
  end

  mount "/"
end
