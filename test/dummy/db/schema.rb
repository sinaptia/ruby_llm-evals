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

ActiveRecord::Schema[8.0].define(version: 2025_10_21_160630) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
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

  create_table "prompt_bench_eval_examples", force: :cascade do |t|
    t.integer "prompt_bench_prompt_id", null: false
    t.string "eval_type", null: false
    t.text "expected_output"
    t.json "variables"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prompt_bench_prompt_id"], name: "index_prompt_bench_eval_examples_on_prompt_bench_prompt_id"
  end

  create_table "prompt_bench_eval_results", force: :cascade do |t|
    t.integer "prompt_bench_prompt_id", null: false
    t.string "active_job_id", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.string "provider", null: false
    t.string "model", null: false
    t.float "temperature"
    t.json "params"
    t.json "tools"
    t.string "schema"
    t.json "schema_other"
    t.text "instructions"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prompt_bench_prompt_id"], name: "index_prompt_bench_eval_results_on_prompt_bench_prompt_id"
  end

  create_table "prompt_bench_prompt_executions", force: :cascade do |t|
    t.integer "prompt_bench_eval_example_id", null: false
    t.integer "prompt_bench_eval_result_id", null: false
    t.string "eval_type", null: false
    t.text "expected_output"
    t.json "variables"
    t.integer "input"
    t.integer "output"
    t.text "message"
    t.boolean "passed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prompt_bench_eval_example_id"], name: "index_pb_prompt_executions_on_pb_eval_example_id"
    t.index ["prompt_bench_eval_result_id"], name: "index_pb_prompt_executions_on_pb_eval_result_id"
  end

  create_table "prompt_bench_prompts", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "provider", null: false
    t.string "model", null: false
    t.float "temperature"
    t.json "params"
    t.json "tools"
    t.string "schema"
    t.json "schema_other"
    t.text "instructions"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_prompt_bench_prompts_on_name", unique: true
    t.index ["slug"], name: "index_prompt_bench_prompts_on_slug", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "prompt_bench_eval_examples", "prompt_bench_prompts"
  add_foreign_key "prompt_bench_eval_results", "prompt_bench_prompts"
  add_foreign_key "prompt_bench_prompt_executions", "prompt_bench_eval_examples"
  add_foreign_key "prompt_bench_prompt_executions", "prompt_bench_eval_results"
end
