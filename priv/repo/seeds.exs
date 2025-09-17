alias EmailNotification.{Repo, Accounts.User, Messaging.Contact}

# --- Superuser ---
superuser =
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

# --- Admin (Gold Plan) ---
admin =
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

# --- Frontend User ---
frontend =
  Repo.insert!(
    %User{
      first_name: "Regular",
      last_name: "Frontend",
      email_address: "frontend@example.com",
      msisdn: "2222222222",
      role: "frontend",
      plan: "standard",
      username: "frontenduser",
      password: "frontendsecret"
    },
    on_conflict: :nothing
  )

# --- Example Contact (attached to superuser) ---
Repo.insert!(
  %Contact{
    name: "John Doe",
    email: "john@example.com",
    user_id: superuser.id
  },
  on_conflict: :nothing
)
