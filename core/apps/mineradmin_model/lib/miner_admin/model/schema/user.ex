defmodule MinerAdmin.Model.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias MinerAdmin.Model
  alias MinerAdmin.Model.Schema
  alias MinerAdmin.Model.Query

  schema "users" do
    field :login, :string
    field :password, :string
    field :role, :integer

    belongs_to :auth_backend, Schema.AuthBackend
    has_many :auth_tokens, Schema.AuthToken

    timestamps()
  end

  def create_changeset(user, params) do
    user
    |> cast(params, [:login, :password, :role, :auth_backend_id])
    |> validate_required([:login, :role])
    |> validate_backend(:create)
    |> foreign_key_constraint(:auth_backend_id)
    |> unique_constraint(:login)
  end

  def update_changeset(user, params) do
    user
    |> cast(params, [:login, :password, :role])
    |> validate_backend(:update, user.auth_backend)
    |> unique_constraint(:login)
  end

  defp validate_backend(changeset, :create) do
    case fetch_change(changeset, :auth_backend_id) do
      {:ok, auth_backend_id} ->
        validate_backend(changeset, :create, Query.AuthBackend.get(auth_backend_id))

      :error ->
        validate_backend(changeset, :create, :default)
    end
  end

  defp validate_backend(changeset, :create, nil) do
    add_error(changeset, :auth_backend_id, "does not exist")
  end

  defp validate_backend(changeset, :update, nil) do
    Model.AuthBackend.user_changeset(:default, changeset, :update)
  end

  defp validate_backend(changeset, type, backend) do
    Model.AuthBackend.user_changeset(backend, changeset, type)
  end
end
