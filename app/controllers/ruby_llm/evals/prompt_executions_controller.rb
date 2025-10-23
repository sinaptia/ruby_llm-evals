module RubyLLM
  module Evals
    class PromptExecutionsController < ApplicationController
      before_action :set_prompt_execution, only: %i[ toggle ]

      def toggle
        @prompt_execution.toggle! :passed

        redirect_to @prompt_execution.run, notice: "Prompt execution was successfully toggled.", status: :see_other
      end

      private

      def set_prompt_execution
        @prompt_execution = PromptExecution.find params[:id]
      end
    end
  end
end
