class CreateRubyLLMEvalsPromptExecutions < ActiveRecord::Migration[7.0]
  def change
    create_table :ruby_llm_evals_prompt_executions do |t|
      t.references :ruby_llm_evals_sample, null: false, foreign_key: true, index: { name: "index_rle_prompt_executions_on_rle_sample_id" }
      t.references :ruby_llm_evals_run, null: false, foreign_key: true, index: { name: "index_rle_prompt_executions_on_rle_run_id" }
      t.string :eval_type, null: false
      t.text :expected_output
      t.json :variables
      t.integer :input
      t.integer :output
      t.text :message
      t.boolean :passed
      t.string :active_job_id, null: true
      t.timestamp :started_at
      t.timestamp :ended_at
      t.text :error_message
      t.string :judge_provider
      t.string :judge_model
      t.json :judge_message
      t.integer :judge_input
      t.integer :judge_output

      t.timestamps
    end
  end
end
