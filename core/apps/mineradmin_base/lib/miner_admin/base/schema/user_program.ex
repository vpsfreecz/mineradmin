defmodule MinerAdmin.Base.Schema.UserProgram do
  use Ecto.Schema
  import Ecto.Changeset
  alias MinerAdmin.Base.Schema

  schema "user_programs" do
    belongs_to :user, Schema.User
    belongs_to :program, Schema.Program
    belongs_to :node, Schema.Node
    field :label, :string
    field :cmdline, :string
    field :active, :boolean, default: false

    many_to_many :gpus, Schema.Gpu, join_through: "user_program_gpus"

    timestamps()
  end

  def create_changeset(user_prog, params) do
    fields = ~w(user_id program_id node_id label)a

    user_prog
    |> cast(params, fields)
    |> validate_required(fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:program_id)
    |> foreign_key_constraint(:node_id)
  end

  def active_changeset(user_prog, params \\ %{}) do
    user_prog
    |> cast(params, [:active])
  end
end
