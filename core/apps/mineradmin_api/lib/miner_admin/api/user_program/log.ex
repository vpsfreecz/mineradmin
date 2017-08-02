defmodule MinerAdmin.Api.UserProgram.Log do
  use HaveAPI.Resource
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  defmodule Params do
    use HaveAPI.Parameters

    integer :id
    string :type, validate: [include: [
      values: Base.Schema.UserProgramLog.Type.__enum_map__
              |> Keyword.keys()
              |> Enum.map(&to_string/1)
    ]]
    custom :opts
    datetime :inserted_at
  end

  resource_route ':userprogram_id/%{resource}'

  actions [
    Api.UserProgram.Log.Index,
    Api.UserProgram.Log.Show,
  ]
end
