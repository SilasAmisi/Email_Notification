# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     EmailNotification.Repo.insert!(%EmailNotification.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias EmailNotification.Repo
alias EmailNotification.Accounts.User
alias EmailNotification.Messaging.Contact

# --- USERS ---
users = [
  %User{
    first_name: "Alice",
    last_name: "Johnson",
    email_address: "alice@example.com",
    msisdn: "254700111111",
    role: "frontend",
    plan: "standard"
  },
  %User{
    first_name: "Bob",
    last_name: "Kamau",
    email_address: "bob@example.com",
    msisdn: "254700222222",
    role: "admin",
    plan: "gold"
  },
  %User{
    first_name: "Carol",
    last_name: "Smith",
    email_address: "carol@example.com",
    msisdn: "254700333333",
    role: "superuser",
    plan: "standard"
  }
]

IO.puts("🌱 Seeding users...")
inserted_users =
  Enum.map(users, fn user ->
    Repo.insert!(user)
  end)

# --- CONTACTS ---
contacts = [
  %Contact{
    user_id: Enum.at(inserted_users, 0).id,
    name: "Daniel Otieno",
    email: "daniel@example.com"
  },
  %Contact{
    user_id: Enum.at(inserted_users, 0).id,
    name: "Evelyn Wanjiku",
    email: "evelyn@example.com"
  },
  %Contact{
    user_id: Enum.at(inserted_users, 1).id,
    name: "Frank Njoroge",
    email: "frank@example.com"
  },
  %Contact{
    user_id: Enum.at(inserted_users, 2).id,
    name: "Grace Mwende",
    email: "grace@example.com"
  }
]

IO.puts("🌱 Seeding contacts...")
Enum.each(contacts, fn contact ->
  Repo.insert!(contact)
end)

IO.puts("✅ Done seeding users and contacts!")
