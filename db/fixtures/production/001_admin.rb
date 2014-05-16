admin = User.create(
  email: "poqbod@poqbod.com",
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

if admin.valid?
puts %q[
Administrator account created:

login.........poqbod@poqbod.com
password......12345678
]
end
