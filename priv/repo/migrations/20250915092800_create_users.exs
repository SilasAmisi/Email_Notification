defmodule EmailNotification.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :email_address, :string, null: false
      add :msisdn, :string
      add :role, :string, default: "frontend"   # frontend, admin, superuser
      add :plan, :string, default: "standard"   # standard, gold

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email_address])
  end
end
