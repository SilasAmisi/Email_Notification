defmodule EmailNotification.Repo.Migrations.CreateGroupContacts do
  use Ecto.Migration

  def change do
    create table(:group_contacts) do
      add :group_id, references(:groups, on_delete: :delete_all), null: false
      add :contact_id, references(:contacts, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:group_contacts, [:group_id, :contact_id])
  end
end
