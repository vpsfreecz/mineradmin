defmodule MinerAdmin.Base.Schema.UserProgram do
  use Ecto.Schema
  import Ecto.Changeset
  alias MinerAdmin.Base
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
    user_prog
    |> cast(params, ~w(user_id program_id node_id label cmdline)a)
    |> validate_required(~w(label)a)
    |> assoc_constraint(:user)
    |> assoc_constraint(:program)
    |> assoc_constraint(:node)
    |> Base.Program.changeset(:create, user_prog)
  end

  def update_changeset(user_prog, params) do
    user_prog
    |> cast(params, ~w(label cmdline)a)
    |> Base.Program.changeset(:update, user_prog)
  end

  def active_changeset(user_prog, params \\ %{}) do
    user_prog
    |> cast(params, [:active])
  end

  def gpus_changeset(changeset) do
    validate_change(changeset, :gpus, fn :gpus, gpus ->
      errors = Enum.reduce(
        gpus,
        [],
        fn gpu, acc ->
          if gpu.data.node_id != changeset.data.node_id do
            ["GPU #{gpu.data.id} is not on node #{changeset.data.node_id}" | acc]

          else
            acc
          end
        end
      )

      if Enum.empty?(errors) do
        []
      else
        [gpus: Enum.join(errors, ", ")]
      end
    end)
  end
end
