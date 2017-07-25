defmodule MinerAdmin.Base.Node do
  def name(node) when is_atom(node) do
    [name, domain] = String.split(Atom.to_string(node), "@")
    {name, domain}
  end
end
