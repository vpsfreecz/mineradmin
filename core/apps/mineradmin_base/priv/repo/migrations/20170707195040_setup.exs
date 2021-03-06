defmodule MinerAdmin.Base.Repo.Migrations.Setup do
  use Ecto.Migration

  def change do
    create table(:nodes) do
      add :name, :string, null: false
      add :domain, :string, null: false

      timestamps()
    end

    create unique_index(:nodes, [:name, :domain], name: :nodes_name_unique)
  end
end
