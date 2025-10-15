class CreatePromptBenchEvalResults < ActiveRecord::Migration[8.0]
  def change
    create_table :prompt_bench_eval_results do |t|
      t.references :prompt_bench_prompt, null: false, foreign_key: true
      t.string :active_job_id, null: false
      t.timestamp :started_at
      t.timestamp :ended_at
      t.string :provider, null: false
      t.string :model, null: false
      t.text :instructions
      t.text :message

      t.timestamps
    end
  end
end
