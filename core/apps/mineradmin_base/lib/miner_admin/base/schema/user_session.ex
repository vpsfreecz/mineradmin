defmodule MinerAdmin.Base.Schema.UserSession do
  use Ecto.Schema
  import Ecto.Changeset
  alias MinerAdmin.Base.Schema

  schema "user_sessions" do
    belongs_to :user, Schema.User
    field :auth_method, :string
    field :opened_at, :utc_datetime
    field :closed_at, :utc_datetime
    field :last_request_at, :utc_datetime
    field :request_count, :integer
    belongs_to :auth_token, Schema.AuthToken
    field :auth_token_str, :string
    field :client_ip_addr, :string
  end

  def create_changeset(session, params \\ %{}) do
    required = ~w(
      user_id auth_method opened_at last_request_at client_ip_addr request_count
    )a

    session
    |> cast(params, [:auth_token_id, :auth_token_str] ++ required)
    |> validate_required(required)
    |> validate_inclusion(:auth_method, ~w(basic token))
    |> validate_length(:auth_token_str, is: 100)
  end

  def update_changeset(session, params \\ %{}) do
    session
    |> cast(params, [:last_request_at, :request_count, :closed_at, :auth_token_id])
  end
end
