defmodule MinerAdmin.Base.Schema.Node do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes" do
    field :name, :string
    field :domain, :string

    has_many :gpus, Schema.Gpu
    has_many :user_programs, Schema.UserProgram

    timestamps()
  end

  def create_changeset(node, params \\ %{}) do
    node
    |> cast(params, [:name, :domain])
    |> validate_required([:name, :domain])
    |> unique_constraint(:name, name: :nodes_name_unique)
  end

  def update_changeset(node, params \\ %{}) do
    node
    |> cast(params, [:name, :domain])
    |> unique_constraint(:name, name: :nodes_name_unique)
  end
end
