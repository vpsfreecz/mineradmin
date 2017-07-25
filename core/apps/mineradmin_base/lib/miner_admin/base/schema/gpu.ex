defmodule MinerAdmin.Base.Schema.Gpu do
  use Ecto.Schema
  import Ecto.Changeset
  alias MinerAdmin.Base.Schema

  import EctoEnum, only: [defenum: 2]
  defenum Vendor, nvidia: 0, amd: 1

  schema "gpus" do
    belongs_to :user, Schema.User
    belongs_to :node, Schema.Node
    field :vendor, Vendor
    field :uuid, :string
    field :name, :string

    timestamps()
  end

  def create_changeset(gpu, params \\ %{}) do
    fields = ~w(user_id node_id vendor uuid)a

    gpu
    |> cast(params, fields)
    |> validate_required(fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:node_id)
    |> unique_constraint(:uuid, name: :gpus_node_id_uuid_index)
  end

  def update_changeset(gpu, params \\ %{}) do
    gpu
    |> cast(params, [:name])
  end
end
