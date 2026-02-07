module RubyLLM
  module Evals
    module PromptExecutions
      module PromptExecutionScoped
        extend ActiveSupport::Concern

        included do
          before_action :set_prompt_execution
        end

        private

        def set_prompt_execution
          @prompt_execution = PromptExecution.find params[:prompt_execution_id]
        end
      end
    end
  end
end
