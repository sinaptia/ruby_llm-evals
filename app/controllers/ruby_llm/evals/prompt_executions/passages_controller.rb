module RubyLLM
  module Evals
    module PromptExecutions
      class PassagesController < ApplicationController
        include PromptExecutionScoped

        def create
          @prompt_execution.update! passed: true

          redirect_to @prompt_execution.run, notice: "Prompt execution marked as passed.", status: :see_other
        end
      end
    end
  end
end
