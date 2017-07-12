defmodule MinerAdmin.Model.Repo.Migrations.AddUserSessions do
  use Ecto.Migration

  def up do
    create table(:user_sessions) do
      add :user_id, references(:users), null: false
      add :auth_method, :string, size: 30, null: false
      add :opened_at, :utc_datetime, null: false
      add :closed_at, :utc_datetime
      add :last_request_at, :utc_datetime, null: false
      add :auth_token_id, references(:auth_tokens)
      add :auth_token_str, :string, size: 100
      add :client_ip_addr, :string, size: 50, null: false
      add :request_count, :integer, null: false, default: 0
    end

    create index(:user_sessions, [:user_id])

    alter table(:auth_tokens) do
      remove :use_count
    end
  end

  def down do
    drop index(:user_sessions, [:user_id])

    drop table(:user_sessions)

    alter table(:auth_tokens) do
      add :use_count, :integer, null: false, default: 0
    end
  end
end
