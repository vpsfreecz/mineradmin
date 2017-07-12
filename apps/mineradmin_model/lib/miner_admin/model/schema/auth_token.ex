defmodule MinerAdmin.Model.Schema.AuthToken do
  use Ecto.Schema
  import Ecto.Changeset
  alias MinerAdmin.Model.Schema

  import EctoEnum, only: [defenum: 2]
  defenum Lifetime, fixed: 0, renewable_manual: 1, renewable_auto: 2, permanent: 3

  schema "auth_tokens" do
    belongs_to :user, Schema.User
    field :token, :string
    field :valid_to, :utc_datetime
    field :interval, :integer
    field :lifetime, Lifetime

    timestamps()
  end

  def create_changeset(token, params \\ %{}) do
    token
    |> cast(params, [:token, :valid_to, :interval, :lifetime])
    |> check_lifetime(token.lifetime)
    |> validate_length(:token, is: 100)
    |> unique_constraint(:token)
  end

  def extend_changeset(token, params \\ %{}) do
    token
    |> cast(params, [:valid_to])
  end

  defp check_lifetime(changeset, :permanent), do: changeset

  defp check_lifetime(changeset, _lifetime) do
    validate_number(
      changeset,
      :interval,
      greater_than_or_equal_to: 60
    )
  end
end
