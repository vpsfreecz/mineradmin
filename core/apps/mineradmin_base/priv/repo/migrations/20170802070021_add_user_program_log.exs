defmodule MinerAdmin.Base.Repo.Migrations.AddUserProgramLog do
  use Ecto.Migration

  def change do
    create table(:user_program_logs) do
      add :user_program_id, references(:user_programs, on_delete: :delete_all), null: false
      add :user_session_id, references(:user_sessions, on_delete: :delete_all)
      add :type, :integer, null: false
      add :opts, :map

      timestamps()
    end

    create index(:user_program_logs, :user_program_id)
    create index(:user_program_logs, :user_session_id)
  end
end
