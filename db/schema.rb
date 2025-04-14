# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_04_14_145111) do
  create_table "bounties", force: :cascade do |t|
    t.decimal "amount"
    t.integer "user_id", null: false
    t.integer "conjecture_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conjecture_id"], name: "index_bounties_on_conjecture_id"
    t.index ["user_id"], name: "index_bounties_on_user_id"
  end

  create_table "conjectures", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.text "falsification_criteria"
    t.integer "status"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_conjectures_on_user_id"
  end

  create_table "refutations", force: :cascade do |t|
    t.text "content"
    t.integer "conjecture_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "accepted"
    t.index ["conjecture_id"], name: "index_refutations_on_conjecture_id"
    t.index ["user_id"], name: "index_refutations_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "conjecture_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conjecture_id"], name: "index_taggings_on_conjecture_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "title"
    t.string "first_name"
    t.string "last_name"
    t.integer "display_name_preference"
    t.string "organization"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "bounties", "conjectures"
  add_foreign_key "bounties", "users"
  add_foreign_key "conjectures", "users"
  add_foreign_key "refutations", "conjectures"
  add_foreign_key "refutations", "users"
  add_foreign_key "taggings", "conjectures"
  add_foreign_key "taggings", "tags"
end
