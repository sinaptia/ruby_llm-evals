class CreatePromptBenchEvalExamples < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def change
    create_table :prompt_bench_eval_examples do |t|
      t.references :prompt_bench_prompt, null: false, foreign_key: true
      t.string :eval_type, null: false
      t.text :expected_output
      t.json :variables

      t.timestamps
    end
  end
end
