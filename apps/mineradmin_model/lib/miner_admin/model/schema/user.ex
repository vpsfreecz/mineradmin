defmodule MinerAdmin.Model.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias MinerAdmin.Model.Schema

  schema "users" do
    field :login, :string
    field :password, :string
    field :role, :integer

    has_many :auth_tokens, Schema.AuthToken

    timestamps()
  end

  def create_changeset(user, params) do
    user
    |> cast(params, [:login, :password, :role])
    |> validate_required([:login, :password, :role])
    |> unique_constraint(:login)
  end

  def update_changeset(user, params) do
    user
    |> cast(params, [:login, :password, :role])
    |> unique_constraint(:login)
  end
end
