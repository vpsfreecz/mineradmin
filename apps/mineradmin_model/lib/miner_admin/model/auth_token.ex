defmodule MinerAdmin.Model.AuthToken do
  alias MinerAdmin.Model
  alias MinerAdmin.Model.Query

  def used(%Model.Schema.AuthToken{lifetime: :renewable_auto} = token) do
    Query.AuthToken.extend(token)
  end

  def used(_token), do: nil
end
