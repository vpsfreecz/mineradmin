defmodule MinerAdmin.Base.Repo.Migrations.AddUserPrograms do
  use Ecto.Migration

  def change do
    create table(:programs) do
      add :label, :string, null: false
      add :description, :string, limit: 65535
      add :module, :string, null: false

      timestamps()
    end

    create table(:user_programs) do
      add :user_id, references(:users), null: false
      add :program_id, references(:programs), null: false
      add :node_id, references(:nodes), null: false
      add :label, :string, null: false
      add :cmdline, :string
      add :active, :boolean, null: false, default: false

      timestamps()
    end

    create index(:user_programs, :user_id)
    create index(:user_programs, :program_id)
    create index(:user_programs, :node_id)
    create index(:user_programs, :active)

    create table(:user_program_gpus, primary_key: false) do
      add :user_program_id, references(:user_programs)
      add :gpu_id, references(:gpus)
    end

    create unique_index(:user_program_gpus, [:user_program_id, :gpu_id])
    create index(:user_program_gpus, :user_program_id)
    create index(:user_program_gpus, :gpu_id)
  end
end
