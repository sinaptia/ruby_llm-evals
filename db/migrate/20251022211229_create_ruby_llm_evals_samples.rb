class CreateRubyLLMEvalsSamples < ActiveRecord::Migration[7.0]
  def change
    create_table :ruby_llm_evals_samples do |t|
      t.references :ruby_llm_evals_prompt, null: false, foreign_key: true
      t.string :eval_type, null: false
      t.text :expected_output
      t.string :judge_model
      t.string :judge_provider
      t.json :variables

      t.timestamps
    end
  end
end
