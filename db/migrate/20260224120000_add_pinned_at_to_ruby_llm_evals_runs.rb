class AddPinnedAtToRubyLLMEvalsRuns < ActiveRecord::Migration[7.2]
  def change
    add_column :ruby_llm_evals_runs, :pinned_at, :datetime
  end
end
