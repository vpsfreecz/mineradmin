defmodule MinerAdmin.Api.UserProgram do
  use HaveAPI.Resource
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  defmodule Params do
    use HaveAPI.Parameters

    integer :id
    resource [Api.User], value_label: :login
    resource [Api.Program]
    resource [Api.Node], value_label: :name
    string :label
    string :cmdline
    boolean :read_only
    boolean :active
    boolean :running
    datetime :inserted_at
    datetime :updated_at
  end

  actions [
    Api.UserProgram.Index,
    Api.UserProgram.Show,
    Api.UserProgram.Create,
    Api.UserProgram.Update,
    Api.UserProgram.Delete,
    Api.UserProgram.Start,
    Api.UserProgram.Stop,
    Api.UserProgram.Restart,
  ]

  resources [
    Api.UserProgram.Gpu,
    Api.UserProgram.Log,
  ]

  def resource(user_prog) when is_map(user_prog) do
    user_prog
    |> Map.put(:running, Api.UserProgram.Monitor.running?(user_prog))
    |> Map.put(:read_only, Base.Program.read_only?(user_prog))
  end

  def resources(user_progs) when is_list(user_progs) do
    for up <- user_progs, do: resource(up)
  end
end
