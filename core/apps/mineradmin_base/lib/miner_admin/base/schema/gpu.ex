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
end
