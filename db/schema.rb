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

ActiveRecord::Schema[8.0].define(version: 2025_02_06_093832) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.string "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "annotations", id: { type: :string, limit: 25 }, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "restricted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["restricted"], name: "index_annotations_on_restricted"
  end

  create_table "annotations_systems", id: false, force: :cascade do |t|
    t.string "annotation_id", limit: 25, null: false
    t.string "system_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["annotation_id", "system_id"], name: "index_annotations_systems_on_annotation_id_and_system_id", unique: true
    t.index ["annotation_id"], name: "index_annotations_systems_on_annotation_id"
    t.index ["system_id"], name: "index_annotations_systems_on_system_id"
  end

  create_table "countries", id: { type: :string, limit: 10 }, force: :cascade do |t|
    t.string "name"
    t.integer "continent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "longitude", precision: 10, scale: 6
    t.decimal "latitude", precision: 10, scale: 6
    t.index ["continent"], name: "index_countries_on_continent"
    t.index ["name"], name: "index_countries_on_name", unique: true
  end

  create_table "generators", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "name"
    t.string "platform_id", limit: 100, null: false
    t.string "version", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_generators_on_name", unique: true
    t.index ["platform_id"], name: "index_generators_on_platform_id"
  end

  create_table "media", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "name"
    t.string "uri"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "media_systems", id: false, force: :cascade do |t|
    t.string "medium_id", limit: 50, null: false
    t.string "system_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["medium_id", "system_id"], name: "index_media_systems_on_medium_id_and_system_id", unique: true
    t.index ["medium_id"], name: "index_media_systems_on_medium_id"
    t.index ["system_id"], name: "index_media_systems_on_system_id"
  end

  create_table "network_checks", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.boolean "passed", default: false
    t.integer "network_check_type"
    t.integer "http_code"
    t.string "description"
    t.string "system_id", limit: 36, null: false
    t.integer "failures", default: 0
    t.datetime "error_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["system_id", "network_check_type"], name: "index_network_checks_on_system_id_and_network_check_type", unique: true
    t.index ["system_id"], name: "index_network_checks_on_system_id"
  end

  create_table "normalids", force: :cascade do |t|
    t.string "url", null: false
    t.string "domain"
    t.string "system_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["system_id"], name: "index_normalids_on_system_id"
  end

  create_table "organisations", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "name"
    t.json "aliases", default: []
    t.string "short_name"
    t.string "ror"
    t.string "location"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "country_id", limit: 10, null: false
    t.string "website"
    t.string "domain"
    t.boolean "rp", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_organisations_on_country_id"
    t.index ["domain"], name: "index_organisations_on_domain"
    t.index ["ror"], name: "index_organisations_on_ror"
    t.index ["rp"], name: "index_organisations_on_rp"
  end

  create_table "organisations_users", id: false, force: :cascade do |t|
    t.string "organisation_id", limit: 36, null: false
    t.string "user_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id", "user_id"], name: "index_organisations_users_on_organisation_id_and_user_id", unique: true
    t.index ["organisation_id"], name: "index_organisations_users_on_organisation_id"
    t.index ["user_id"], name: "index_organisations_users_on_user_id"
  end

  create_table "passwordless_sessions", force: :cascade do |t|
    t.string "authenticatable_type"
    t.string "authenticatable_id"
    t.datetime "timeout_at", precision: nil, null: false
    t.datetime "expires_at", precision: nil, null: false
    t.datetime "claimed_at", precision: nil
    t.string "token_digest", null: false
    t.string "identifier", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authenticatable_type", "authenticatable_id"], name: "authenticatable"
    t.index ["identifier"], name: "index_passwordless_sessions_on_identifier", unique: true
  end

  create_table "platforms", id: { type: :string, limit: 100 }, force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.boolean "trusted", default: false
    t.boolean "oai_support", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "oai_suffix"
    t.string "matchers", array: true
    t.float "match_order", default: 100.0
    t.string "generator_patterns", array: true
    t.index ["match_order"], name: "index_platforms_on_match_order"
    t.index ["oai_support"], name: "index_platforms_on_oai_support"
  end

  create_table "repoids", force: :cascade do |t|
    t.integer "identifier_scheme", null: false
    t.string "identifier_value", null: false
    t.string "system_id", limit: 36, null: false
    t.index ["identifier_scheme", "identifier_value", "system_id"], name: "idx_on_identifier_scheme_identifier_value_system_id_1a6a992bab", unique: true
    t.index ["identifier_scheme"], name: "index_repoids_on_identifier_scheme"
    t.index ["identifier_value"], name: "index_repoids_on_identifier_value"
    t.index ["system_id"], name: "index_repoids_on_system_id"
  end

  create_table "roles", id: { type: :string, limit: 30 }, force: :cascade do |t|
    t.string "name", limit: 30
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.string "role_id", limit: 30, null: false
    t.string "user_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id", "user_id"], name: "index_roles_users_on_role_id_and_user_id", unique: true
    t.index ["role_id"], name: "index_roles_users_on_role_id"
    t.index ["user_id"], name: "index_roles_users_on_user_id"
  end

  create_table "systems", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "name"
    t.json "aliases", default: []
    t.string "short_name"
    t.string "url"
    t.text "description"
    t.integer "system_status", default: 0
    t.integer "oai_status", default: 0
    t.string "platform_id", limit: 100, null: false
    t.string "platform_version"
    t.integer "record_status", default: 0
    t.string "record_source", limit: 50
    t.string "owner_id", limit: 36
    t.string "rp_id", limit: 36
    t.string "country_id", limit: 100
    t.string "generator_id", limit: 36
    t.string "contact"
    t.integer "random_id", default: 0, null: false
    t.json "metadata", default: {}
    t.json "formats", default: {}
    t.integer "system_category", default: 0
    t.integer "subcategory", default: 0
    t.json "issues", default: {}
    t.integer "primary_subject", default: 0
    t.string "oai_base_url"
    t.datetime "reviewed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_systems_on_country_id"
    t.index ["generator_id"], name: "index_systems_on_generator_id"
    t.index ["oai_status"], name: "index_systems_on_oai_status"
    t.index ["owner_id"], name: "index_systems_on_owner_id"
    t.index ["platform_id"], name: "index_systems_on_platform_id"
    t.index ["record_status"], name: "index_systems_on_record_status"
    t.index ["reviewed"], name: "index_systems_on_reviewed"
    t.index ["rp_id"], name: "index_systems_on_rp_id"
    t.index ["system_status"], name: "index_systems_on_system_status"
  end

  create_table "systems_users", id: false, force: :cascade do |t|
    t.string "system_id", limit: 36, null: false
    t.string "user_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["system_id", "user_id"], name: "index_systems_users_on_system_id_and_user_id", unique: true
    t.index ["system_id"], name: "index_systems_users_on_system_id"
    t.index ["user_id"], name: "index_systems_users_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.string "taggable_id", limit: 36
    t.string "tagger_type"
    t.string "tagger_id", limit: 36
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "email", null: false
    t.string "fore_name"
    t.string "last_name"
    t.boolean "verified", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "access_revoked", default: false
    t.string "api_key_digest"
    t.index ["api_key_digest"], name: "index_users_on_api_key_digest", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "annotations_systems", "annotations"
  add_foreign_key "annotations_systems", "systems"
  add_foreign_key "generators", "platforms"
  add_foreign_key "media_systems", "media"
  add_foreign_key "media_systems", "systems"
  add_foreign_key "network_checks", "systems"
  add_foreign_key "normalids", "systems"
  add_foreign_key "organisations", "countries"
  add_foreign_key "organisations_users", "organisations"
  add_foreign_key "organisations_users", "users"
  add_foreign_key "repoids", "systems"
  add_foreign_key "roles_users", "roles"
  add_foreign_key "roles_users", "users"
  add_foreign_key "systems", "countries"
  add_foreign_key "systems", "generators"
  add_foreign_key "systems", "organisations", column: "owner_id"
  add_foreign_key "systems", "organisations", column: "rp_id"
  add_foreign_key "systems", "platforms"
  add_foreign_key "systems_users", "systems"
  add_foreign_key "systems_users", "users"
  add_foreign_key "taggings", "tags"
end
