defmodule MinerAdmin.Base.Schema.Program do
  use Ecto.Schema
  import Ecto.Changeset
  alias MinerAdmin.Base.Schema

  schema "programs" do
    field :label, :string
    field :description, :string
    field :module, :string

    timestamps()
  end

  def create_changeset(prog, params) do
    prog
    |> cast(params, [:label, :description, :module])
    |> validate_required([:label, :module])
  end

  def update_changeset(prog, params \\ %{}) do
    prog
    |> cast(params, [:label, :description])
  end
end
