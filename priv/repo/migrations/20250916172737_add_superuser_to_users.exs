defmodule EmailNotification.Repo.Migrations.AddSuperuserToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :superuser, :boolean, default: false, null: false
    end
  end
end
