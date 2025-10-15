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

ActiveRecord::Schema[8.0].define(version: 2025_10_15_022047) do
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
    t.index ["prompt_bench_eval_example_id"], name: "idx_on_prompt_bench_eval_example_id_e361863871"
    t.index ["prompt_bench_eval_result_id"], name: "idx_on_prompt_bench_eval_result_id_1a669ecd62"
  end

  create_table "prompt_bench_prompts", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "provider", null: false
    t.string "model", null: false
    t.text "instructions"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_prompt_bench_prompts_on_name", unique: true
    t.index ["slug"], name: "index_prompt_bench_prompts_on_slug", unique: true
  end

  add_foreign_key "prompt_bench_eval_examples", "prompt_bench_prompts"
  add_foreign_key "prompt_bench_eval_results", "prompt_bench_prompts"
  add_foreign_key "prompt_bench_prompt_executions", "prompt_bench_eval_examples"
  add_foreign_key "prompt_bench_prompt_executions", "prompt_bench_eval_results"
end
