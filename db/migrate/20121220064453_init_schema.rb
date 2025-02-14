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
      t.string   "service_id"
      t.integer  "post_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "action"
      t.integer  "user_id"
      t.integer  "author_id"
      t.datetime  "stars_at"
      t.datetime  "read_at"
      t.datetime  "book_at"
      t.datetime  "archive_at"
    end

    add_index "events", ["action"], name: "index_events_on_action", using: :btree
    add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree
    add_index "events", ["created_at"], name: "index_events_on_created_at", using: :btree
    add_index "events", ["service_id"], name: "index_events_on_service_id", using: :btree
    add_index "events", ["post_id"], name: "index_events_on_post_id", using: :btree
    add_index "events", ["author_id"], name: "index_events_on_author_id", using: :btree
    add_index "events", ["stars_at"], name: "index_events_on_stars_at", using: :btree
    add_index "events", ["post_id","user_id"], name: "index_events_on_post_id_and_user_id", unique: true, using: :btree

    create_table "posts", force: true do |t|
      t.string   "title"
      t.integer  "author_id"
      t.string   "provider"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "position",     default: 0
      t.text     "description"
      t.string   "guid"
      t.string   "link",  limit: 1024
      t.integer  "favourite_count", default: 0
      t.integer  "gloabl_share_to_chat_count", default: 0
      t.text     "data"
    end
    execute %{ALTER TABLE posts MODIFY title varchar(255) COLLATE utf8mb4_general_ci NOT NULL}
    execute %{ALTER TABLE posts MODIFY description text COLLATE utf8mb4_general_ci}
    execute %{ALTER TABLE posts MODIFY data text COLLATE utf8mb4_general_ci}

    add_index "posts", ["author_id"], name: "index_posts_on_author_id", using: :btree
    add_index "posts", ["guid","provider"], name: "index_posts_on_guid_and_provider", unique: true, using: :btree

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

    create_table "authors", force: true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.string   "slug"
      t.text     "description"
      t.string   "provider"
      t.string   "avatar"
      t.string   "profile_url"
      t.string   "guid"
      t.text     "data"
    end

    add_index "authors", ["slug"], name: "index_authors_on_slug", using: :btree
    add_index "authors", ["guid","provider"], name: "index_authors_on_guid_and_provider", unique: true, using: :btree

    execute %{ALTER TABLE authors MODIFY name varchar(255) COLLATE utf8mb4_general_ci}
    execute %{ALTER TABLE authors MODIFY data text COLLATE utf8mb4_general_ci}

    create_table "services", force: true do |t|
      t.string   "service_name"
      t.string   "uid"
      t.string   "access_token"
      t.string   "access_secret"
      t.string   "provider"
      t.text     "info"
      t.string   "nickname"
      t.integer  "user_id",                        null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
      t.boolean  "active",      default: false, null: false
      t.datetime "last_activity_at"
      t.string   "since_id"
      t.datetime "last_read_time"
      t.integer  "last_unread_count", default: 0
    end

    add_index "services", ["user_id"], name: "index_services_on_user_id", using: :btree
    add_index "services", ["active"], name: "index_services_on_active", using: :btree
    add_index "services", ["uid","service_name"], name: "index_services_on_uid_and_service_name", unique: true, using: :btree

    create_table "photos", force: true do |t|
      t.string   "image"
      t.integer  "post_id"
      t.string   "provider"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
    end

    add_index "photos", ["post_id"], name: "index_photos_on_post_id", using: :btree
    add_index "photos", ["post_id","image"], name: "index_photos_on_post_id_and_image", unique: true, using: :btree
    add_index "photos", ["provider"], name: "index_photos_on_provider", using: :btree

    create_table "snippets", force: true do |t|
      t.string   "title"
      t.text     "content",    limit: 2147483647
      t.integer  "user_id",                                    null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "file_name"
      t.datetime "expires_at"
      t.boolean  "private",                       default: true, null: false
      t.string   "type"
    end

    add_index "snippets", ["user_id"], name: "index_snippets_on_user_id", using: :btree
    add_index "snippets", ["created_at"], name: "index_snippets_on_created_at", using: :btree
    add_index "snippets", ["expires_at"], name: "index_snippets_on_expires_at", using: :btree

    create_table "notes", force: true do |t|
      t.text     "note"
      t.string   "noteable_type"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "post_id"
      t.string   "attachment"
      t.integer  "noteable_id"
      t.boolean  "system",        default: false, null: false
    end

    add_index "notes", ["user_id"], name: "index_notes_on_user_id", using: :btree
    add_index "notes", ["created_at"], name: "index_notes_on_created_at", using: :btree
    add_index "notes", ["noteable_id", "noteable_type"], name: "index_notes_on_noteable_id_and_noteable_type", using: :btree
    add_index "notes", ["noteable_type"], name: "index_notes_on_noteable_type", using: :btree
    add_index "notes", ["post_id", "noteable_type"], name: "index_notes_on_post_id_and_noteable_type", using: :btree
    add_index "notes", ["post_id"], name: "index_notes_on_post_id", using: :btree
    add_index "notes", ["updated_at"], name: "index_notes_on_updated_at", using: :btree
    execute %{ALTER TABLE notes MODIFY note text COLLATE utf8mb4_general_ci}

    create_table "tmp_files", force: true do |t|
      t.text     "note"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def down
    raise "Can not revert initial migration"
  end
end
