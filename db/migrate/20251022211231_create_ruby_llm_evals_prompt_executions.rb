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

      t.timestamps
    end
  end
end
