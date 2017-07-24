defmodule MinerAdmin.Base.Repo.Migrations.AddUserGpus do
  use Ecto.Migration

  def change do
    create table(:gpus) do
      add :user_id, references(:users), null: false
      add :node_id, references(:nodes), null: false
      add :vendor, :integer, null: false
      add :uuid, :string, null: false
      add :name, :string

      timestamps()
    end

    create index(:gpus, :user_id)
    create index(:gpus, :node_id)
    create index(:gpus, :vendor)
    create index(:gpus, :name)
    create unique_index(:gpus, [:node_id, :uuid])
  end
end
