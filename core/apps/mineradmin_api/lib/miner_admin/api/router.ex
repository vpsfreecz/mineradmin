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

  def child_spec do
    Plug.Adapters.Cowboy.child_spec(
      :http,
      MinerAdmin.Api.Router,
      [],
      [port: 4000, dispatch: dispatch_table()]
    )
  end

  defp dispatch_table do
    [
      {:_, [
        {"/user-program-io", Api.UserProgram.WebSocket, [auth_chain: [
          Api.Authentication.Basic,
          Api.Authentication.Token,
        ]]},
        {:_, Plug.Adapters.Cowboy.Handler, {Api.Router, []}},
      ]}
    ]
  end
end
