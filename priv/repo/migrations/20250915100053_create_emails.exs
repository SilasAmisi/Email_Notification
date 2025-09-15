defmodule EmailNotification.Repo.Migrations.CreateEmails do
  use Ecto.Migration
  def change do
    create table(:emails) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :contact_id, references(:contacts, on_delete: :nilify_all)
      add :group_id, references(:groups, on_delete: :nilify_all)
      add :subject, :string, null: false
      add :body, :text, null: false
      add :status, :string, default: "pending" # pending, sent, failed

      timestamps()
    end

    create index(:emails, [:user_id])
    create index(:emails, [:contact_id])
    create index(:emails, [:group_id])
  end
end
