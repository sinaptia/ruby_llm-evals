class CreateRubyLLMEvalsRuns < ActiveRecord::Migration[7.0]
  def change
    create_table :ruby_llm_evals_runs do |t|
      t.references :ruby_llm_evals_prompt, null: false, foreign_key: true
      t.string :active_job_id, null: false
      t.timestamp :started_at
      t.timestamp :ended_at
      t.string :provider, null: false
      t.string :model, null: false
      t.float :temperature
      t.json :params
      t.json :tools
      t.string :schema
      t.json :schema_other
      t.text :instructions
      t.text :message

      t.timestamps
    end
  end
end
