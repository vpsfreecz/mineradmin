defmodule MinerAdmin.Base.Repo.Migrations.AddUserProgramsGpusOnDelete do
  use Ecto.Migration

  def up do
    execute """
    ALTER TABLE user_program_gpus
    DROP CONSTRAINT user_program_gpus_user_program_id_fkey
    """
    alter table(:user_program_gpus) do
      modify :user_program_id, references(:user_programs, on_delete: :delete_all)
    end
  end

  def down do
    execute """
    ALTER TABLE user_program_gpus
    DROP CONSTRAINT user_program_gpus_user_program_id_fkey
    """
    alter table(:user_program_gpus) do
      modify :user_program_id, references(:user_programs, on_delete: :nothing)
    end
  end
end
