defmodule MinerAdmin.Base.AuthToken do
  alias MinerAdmin.Base
  alias MinerAdmin.Base.Query

  def used(%Base.Schema.AuthToken{lifetime: :renewable_auto} = token) do
    Query.AuthToken.extend(token)
  end

  def used(_token), do: nil
end
