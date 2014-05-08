User.seed(:id, [
  {
    id: 1,
    name: "Administrator",
    email: "admin@local.host",
    username: 'root',
    password: "12345678",
    password_confirmation: "12345678",
    admin: true,
    projects_limit: 100,
    theme_id: Gitlab::Theme::MARS,
    confirmed_at: DateTime.now
  }
])