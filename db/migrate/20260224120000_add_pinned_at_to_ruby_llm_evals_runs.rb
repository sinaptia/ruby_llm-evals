class AddPinnedAtToRubyLLMEvalsRuns < ActiveRecord::Migration[7.2]
  def change
    add_column :ruby_llm_evals_runs, :pinned_at, :datetime

    add_index :ruby_llm_evals_runs, :ruby_llm_evals_prompt_id, unique: true, where: "pinned_at IS NOT NULL", name: "index_ruby_llm_evals_runs_on_prompt_id_pinned"
  end
end
