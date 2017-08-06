defmodule MinerAdmin.Api.Node do
  use HaveAPI.Resource

  defmodule Params do
    use HaveAPI.Parameters

    integer :id
    string :name
    string :domain
    boolean :alive
  end

  actions [
    MinerAdmin.Api.Node.Index,
    MinerAdmin.Api.Node.Show,
    MinerAdmin.Api.Node.Create,
    MinerAdmin.Api.Node.Update,
    MinerAdmin.Api.Node.Delete,
  ]

  def resource(node, list \\ alive_nodes()) when is_map(node) do
    Map.put(node, :alive, :"#{node.name}@#{node.domain}" in list)
  end

  def resources(nodes) when is_list(nodes) do
    list = alive_nodes()
    for n <- nodes, do: resource(n, list)
  end

  defp alive_nodes, do: [Node.self | Node.list]
end
