class InitSchema < ActiveRecord::Migration
  def up
    create_table "broadcast_messages", force: true do |t|
      t.text     "message",    null: false
      t.datetime "starts_at"
      t.datetime "ends_at"
      t.integer  "alert_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "color"
      t.string   "font"
    end

    create_table "emails", force: true do |t|
      t.integer  "user_id",    null: false
      t.string   "email",      null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "emails", ["email"], name: "index_emails_on_email", unique: true, using: :btree
    add_index "emails", ["user_id"], name: "index_emails_on_user_id", using: :btree

    create_table "events", force: true do |t|
      t.string   "target_type"
      t.integer  "target_id"
      t.integer  "project_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "action"
      t.integer  "author_id"
    end

    add_index "events", ["action"], name: "index_events_on_action", using: :btree
    add_index "events", ["author_id"], name: "index_events_on_author_id", using: :btree
    add_index "events", ["created_at"], name: "index_events_on_created_at", using: :btree
    add_index "events", ["project_id"], name: "index_events_on_project_id", using: :btree
    add_index "events", ["target_id"], name: "index_events_on_target_id", using: :btree
    add_index "events", ["target_type"], name: "index_events_on_target_type", using: :btree

    create_table "posts", force: true do |t|
      t.string   "title"
      t.integer  "author_id"
      t.integer  "service"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "position",     default: 0
      t.text     "description"
      t.integer  "guid"
      t.text     "data"
    end

    add_index "posts", ["author_id"], name: "index_posts_on_author_id", using: :btree
    add_index "posts", ["created_at"], name: "index_posts_on_created_at", using: :btree
    add_index "posts", ["service", "guid"], name: "index_posts_on_service_and_guid", unique: true, using: :btree
    add_index "posts", ["service"], name: "index_posts_on_service", using: :btree
    add_index "posts", ["title"], name: "index_posts_on_title", using: :btree

    create_table "keys", force: true do |t|
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "key"
      t.string   "title"
      t.string   "type"
      t.string   "fingerprint"
    end

    add_index "keys", ["user_id"], name: "index_keys_on_user_id", using: :btree

    create_table "projects", force: true do |t|
      t.string   "name"
      t.string   "slug"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "creator_id"
    end

    add_index "projects", ["creator_id"], name: "index_projects_on_creator_id", using: :btree

    create_table "taggings", force: true do |t|
      t.integer  "tag_id"
      t.integer  "taggable_id"
      t.string   "taggable_type"
      t.integer  "tagger_id"
      t.string   "tagger_type"
      t.string   "context"
      t.datetime "created_at"
    end

    add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
    add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

    create_table "tags", force: true do |t|
      t.string "name"
    end

    create_table "users", force: true do |t|
      t.string   "email",                    default: "",    null: false
      t.string   "encrypted_password",       default: "",    null: false
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",            default: 0
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip"
      t.string   "last_sign_in_ip"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.boolean  "admin",                    default: false, null: false
      t.integer  "projects_limit",           default: 10
      t.string   "skype",                    default: "",    null: false
      t.string   "linkedin",                 default: "",    null: false
      t.string   "twitter",                  default: "",    null: false
      t.string   "authentication_token"
      t.integer  "theme_id",                 default: 1,     null: false
      t.string   "bio"
      t.integer  "failed_attempts",          default: 0
      t.datetime "locked_at"
      t.string   "extern_uid"
      t.string   "provider"
      t.string   "username"
      t.boolean  "can_create_group",         default: true,  null: false
      t.boolean  "can_create_team",          default: true,  null: false
      t.string   "state"
      t.integer  "color_scheme_id",          default: 1,     null: false
      t.integer  "notification_level",       default: 1,     null: false
      t.datetime "password_expires_at"
      t.integer  "created_by_id"
      t.string   "avatar"
      t.string   "confirmation_token"
      t.datetime "confirmed_at"
      t.datetime "confirmation_sent_at"
      t.string   "unconfirmed_email"
      t.boolean  "hide_no_ssh_key",          default: false
      t.string   "website_url",              default: "",    null: false
      t.datetime "last_credential_check_at"
    end

    add_index "users", ["admin"], name: "index_users_on_admin", using: :btree
    add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
    add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    add_index "users", ["current_sign_in_at"], name: "index_users_on_current_sign_in_at", using: :btree
    add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
    add_index "users", ["extern_uid", "provider"], name: "index_users_on_extern_uid_and_provider", unique: true, using: :btree
    add_index "users", ["name"], name: "index_users_on_name", using: :btree
    add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    add_index "users", ["username"], name: "index_users_on_username", using: :btree

    create_table "users_projects", force: true do |t|
      t.integer  "user_id",                        null: false
      t.integer  "project_id",                     null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "notification_level", default: 3, null: false
    end

    add_index "users_projects", ["project_id"], name: "index_users_projects_on_project_id", using: :btree
    add_index "users_projects", ["user_id"], name: "index_users_projects_on_user_id", using: :btree

    create_table "authors", force: true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.integer  "service"
      t.string   "guid"
      t.string   "data"
    end

    add_index "authors", ["guid"], name: "index_authors_on_guid", using: :btree
    add_index "authors", ["service"], name: "index_authors_on_service", using: :btree

    create_table "services", force: true do |t|
      t.string   "type"
      t.string   "uid"
      t.string   "access_token"
      t.string   "access_secret"
      t.string   "provider"
      t.text     "info"
      t.string   "nickname"
      t.integer  "user_id",                        null: false
      t.integer  "users_project_id",                  null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "active",      default: false, null: false
      t.integer  "access",     default: 0, null: false
      t.datetime "last_activity_at"
    end

    add_index "services", ["user_id"], name: "index_services_on_user_id", using: :btree
    add_index "services", ["users_project_id"], name: "index_services_on_users_project_id", using: :btree
    add_index "services", ["access"], name: "index_services_on_access", using: :btree
    add_index "services", ["last_activity_at"], name: "index_services_on_last_activity_at", using: :btree

  end

  def down
    raise "Can not revert initial migration"
  end
end
