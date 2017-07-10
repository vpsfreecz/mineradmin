defmodule MinerAdmin.Model.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :login, :string, size: 100, null: false
      add :password, :string, size: 100
      add :role, :integer, null: false

      timestamps()
    end

    create unique_index(:users, :login)

    create table(:auth_tokens) do
      add :user_id, references(:users), null: false
      add :token, :string, size: 100, null: false
      add :valid_to, :utc_datetime
      add :interval, :integer
      add :lifetime, :integer
      add :use_count, :integer, null: false, default: 0

      timestamps()
    end

    create unique_index(:auth_tokens, :token)
  end
end
