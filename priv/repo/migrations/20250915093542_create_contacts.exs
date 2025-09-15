defmodule EmailNotification.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :email, :string, null: false

      timestamps()
    end

    create index(:contacts, [:user_id])
  end
end
