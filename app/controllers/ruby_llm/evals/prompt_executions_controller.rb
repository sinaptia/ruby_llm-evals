module RubyLLM
  module Evals
    class PromptExecutionsController < ApplicationController
      before_action :set_prompt_execution, only: %i[ fail pass retry ]

      def fail
        @prompt_execution.update! passed: false

        redirect_to @prompt_execution.run, notice: "Prompt execution marked as failed.", status: :see_other
      end

      def pass
        @prompt_execution.update! passed: true

        redirect_to @prompt_execution.run, notice: "Prompt execution marked as passed.", status: :see_other
      end

      def retry
        @prompt_execution.retry_job
        redirect_to @prompt_execution.run, notice: "Prompt execution retried.", status: :see_other
      rescue StandardError => e
        redirect_to @prompt_execution.run, alert: "Failed to retry: #{e.message}", status: :see_other
      end

      private

      def set_prompt_execution
        @prompt_execution = PromptExecution.find params[:id]
      end
    end
  end
end
