class AddThinkingEffortAndThinkingBudgetToRubyLLMEvalsRuns < ActiveRecord::Migration[7.2]
  def change
    add_column :ruby_llm_evals_runs, :thinking_effort, :string
    add_column :ruby_llm_evals_runs, :thinking_budget, :integer
  end
end
