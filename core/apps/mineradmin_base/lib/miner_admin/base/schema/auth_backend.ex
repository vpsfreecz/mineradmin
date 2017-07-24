defmodule MinerAdmin.Base.Schema.AuthBackend do
  use Ecto.Schema
  import Ecto.Changeset
  alias MinerAdmin.Base.Schema

  schema "auth_backends" do
    field :label, :string
    field :module, :string
    field :opts, :map

    has_many :users, Schema.User
  end

  def create_changeset(auth_backend, params \\ %{}) do
    auth_backend
    |> cast(params, [:label, :module, :opts])
    |> validate_required([:label, :module, :opts])
  end
end
