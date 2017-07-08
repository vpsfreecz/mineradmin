defmodule MinerAdmin.Model.Query.Node do
  def all, do: MinerAdmin.Model.Repo.all(MinerAdmin.Model.Schema.Node)
end
