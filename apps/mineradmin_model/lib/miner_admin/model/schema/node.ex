defmodule MinerAdmin.Model.Schema.Node do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes" do
    field :name, :string
    field :domain, :string

    timestamps()
  end

  def changeset(node, params \\ %{}) do
    node
    |> cast(params, [:name, :domain])
    |> unique_constraint(:name, name: :nodes_name_unique)
  end
end
