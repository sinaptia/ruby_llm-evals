module PromptBench
  class PromptExecutionsController < ApplicationController
    include PromptScoped, EvalResultScoped

    before_action :set_prompt_execution, only: %i[ toggle ]

    # PATCH/PUT /prompts/:prompt_id/eval_results/:eval_result_id/prompt_executions/1/toggle
    def toggle
      @prompt_execution.toggle! :passed

      redirect_to [ @prompt, @eval_result ], notice: "Prompt execution was successfully toggled.", status: :see_other
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_prompt_execution
        @prompt_execution = @eval_result.prompt_executions.find(params.expect(:id))
      end
  end
end
