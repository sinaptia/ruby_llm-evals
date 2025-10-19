class CreatePromptBenchPromptExecutions < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def change
    create_table :prompt_bench_prompt_executions do |t|
      t.references :prompt_bench_eval_example, null: false, foreign_key: true, index: {name: 'index_pb_prompt_executions_on_pb_eval_example_id'}
      t.references :prompt_bench_eval_result, null: false, foreign_key: true, index: {name: 'index_pb_prompt_executions_on_pb_eval_result_id'}
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
