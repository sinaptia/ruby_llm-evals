class AddThinkingEffortAndThinkingBudgetToRubyLLMEvalsPrompts < ActiveRecord::Migration[7.2]
  def change
    add_column :ruby_llm_evals_prompts, :thinking_effort, :string
    add_column :ruby_llm_evals_prompts, :thinking_budget, :integer
  end
end
