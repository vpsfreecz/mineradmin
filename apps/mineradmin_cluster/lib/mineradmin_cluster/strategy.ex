defmodule MinerAdmin.Cluster.Strategy do
  use Cluster.Strategy

  def start_link(opts) do
    topology = Keyword.fetch!(opts, :topology)
    connect  = Keyword.fetch!(opts, :connect)
    list_nodes = Keyword.fetch!(opts, :list_nodes)

    nodes = Enum.map(
      MinerAdmin.Model.Query.Node.all,
      &(String.to_atom(&1.name <> "@" <> &1.domain))
    )

    case nodes do
      [] ->
        :ignore

      nodes when is_list(nodes) ->
        Cluster.Strategy.connect_nodes(topology, connect, list_nodes, nodes)
        :ignore
    end
  end
end
