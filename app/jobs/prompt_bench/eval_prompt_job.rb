module PromptBench
  class EvalPromptJob < ApplicationJob
    queue_as :default

    def perform(prompt_id:)
      prompt = Prompt.find prompt_id

      eval_result = prompt.eval_results.create active_job_id: job_id, started_at: Time.current

      prompt.samples.each do |sample|
        PromptExecution.execute(sample:, eval_result:)
      end

      eval_result.update ended_at: Time.current
    end
  end
end
