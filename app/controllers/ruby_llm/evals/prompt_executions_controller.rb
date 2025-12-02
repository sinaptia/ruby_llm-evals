module RubyLLM
  module Evals
    class PromptExecutionsController < ApplicationController
      before_action :set_prompt_execution, only: %i[ fail pass ]

      def fail
        @prompt_execution.update! passed: false

        redirect_to @prompt_execution.run, notice: "Prompt execution marked as failed.", status: :see_other
      end

      def pass
        @prompt_execution.update! passed: true

        redirect_to @prompt_execution.run, notice: "Prompt execution marked as passed.", status: :see_other
      end

      private

      def set_prompt_execution
        @prompt_execution = PromptExecution.find params[:id]
      end
    end
  end
end
