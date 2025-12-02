module RubyLLM
  module Evals
    class ExecuteSampleJob < ApplicationJob
      queue_as :default

      def perform(run_id:, sample_id:)
        run = Run.find run_id
        sample = Sample.find sample_id

        prompt_execution = PromptExecution.find_or_create_by(active_job_id: job_id, run:, sample:)
        prompt_execution.update(started_at: Time.current, error_message: nil)

        prompt_execution.execute

        prompt_execution.update ended_at: Time.current

        if run.prompt_executions.count == run.prompt.samples.count
          run.update ended_at: Time.current
        end
      rescue StandardError => e
        prompt_execution&.update error_message: e.message
        raise
      end
    end
  end
end
