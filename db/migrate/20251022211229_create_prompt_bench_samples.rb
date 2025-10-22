class CreatePromptBenchSamples < ActiveRecord::Migration[7.0]
  def change
    create_table :prompt_bench_samples do |t|
      t.references :prompt_bench_prompt, null: false, foreign_key: true
      t.string :eval_type, null: false
      t.text :expected_output
      t.json :variables

      t.timestamps
    end
  end
end
