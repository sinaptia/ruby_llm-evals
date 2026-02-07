module RubyLLM
  module Evals
    module PromptExecutions
      class FailuresController < ApplicationController
        include PromptExecutionScoped

        def create
          @prompt_execution.update! passed: false

          redirect_to @prompt_execution.run, notice: "Prompt execution marked as failed.", status: :see_other
        end
      end
    end
  end
end
