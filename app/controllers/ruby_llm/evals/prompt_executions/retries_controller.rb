module RubyLLM
  module Evals
    module PromptExecutions
      class RetriesController < ApplicationController
        include PromptExecutionScoped

        def create
          @prompt_execution.retry_job
          redirect_to @prompt_execution.run, notice: "Prompt execution retried.", status: :see_other
        rescue StandardError => e
          redirect_to @prompt_execution.run, alert: "Failed to retry: #{e.message}", status: :see_other
        end
      end
    end
  end
end
