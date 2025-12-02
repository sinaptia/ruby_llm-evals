module RubyLLM
  module Evals
    class PerformRunJob < ApplicationJob
      queue_as :default

      def perform(prompt_id:)
        prompt = Prompt.find prompt_id

        run = prompt.runs.create active_job_id: job_id, started_at: Time.current

        if prompt.samples.any?
          prompt.samples.each do |sample|
            ExecuteSampleJob.perform_later(run_id: run.id, sample_id: sample.id)
          end
        else
          run.update ended_at: Time.current
        end
      end
    end
  end
end
