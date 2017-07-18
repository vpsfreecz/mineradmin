defmodule MinerAdmin.Model.Repo.Migrations.AddUserAuthBackends do
  use Ecto.Migration

  def change do
    create table(:auth_backends) do
      add :label, :string
      add :module, :string
      add :opts, :map
    end

    alter table(:users) do
      add :auth_backend_id, references(:auth_backends)
    end
  end
end
