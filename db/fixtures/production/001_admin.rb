admin = User.create(
  email: "admin@local.host",
  name: "Administrator",
  username: 'root',
  password: "12345678",
  password_confirmation: "12345678",
  password_expires_at: Time.now,
  theme_id: Gitlab::Theme::MARS

)

admin.projects_limit = 10000
admin.admin = true
admin.save!
admin.confirm!

Project.seed(:id, [
    { id: 1,  name: "To-Do", slug: 'todo', description: "", creator_id: "1" },
    { id: 2,  name: "Important", slug: 'importmant', description: "", creator_id: "1" },
    { id: 3,  name: "Normal", slug: 'normal', description: "", creator_id: "1" },
    { id: 4,  name: "Low", slug: 'low', description: "", creator_id: "1" },
])

if admin.valid?
puts %q[
Administrator account created:

login.........admin@local.host
password......5iveL!fe
]
end
