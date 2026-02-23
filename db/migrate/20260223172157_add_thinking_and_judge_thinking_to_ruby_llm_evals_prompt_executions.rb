class AddThinkingAndJudgeThinkingToRubyLLMEvalsPromptExecutions < ActiveRecord::Migration[7.2]
  def change
    add_column :ruby_llm_evals_prompt_executions, :thinking, :integer
    add_column :ruby_llm_evals_prompt_executions, :judge_thinking, :integer
  end
end
