defmodule EmailNotification.Repo.Migrations.CreateGroups do
  use Ecto.Migration
  def change do
    create table(:groups) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :name, :string, null: false

      timestamps()
    end

    create index(:groups, [:user_id])
  end
end
