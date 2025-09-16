alias EmailNotification.{Repo, Accounts.User}

# Superuser
Repo.insert!(
  %User{
    first_name: "Super",
    last_name: "User",
    email_address: "super@example.com",
    msisdn: "0000000000",
    role: "superuser",
    plan: "gold",
    username: "superadmin",
    password: "supersecret"
  },
  on_conflict: :nothing
)

# Admin (Gold Plan)
Repo.insert!(
  %User{
    first_name: "Gold",
    last_name: "Admin",
    email_address: "admin@example.com",
    msisdn: "1111111111",
    role: "admin",
    plan: "gold",
    username: "goldadmin",
    password: "adminsecret"
  },
  on_conflict: :nothing
)
