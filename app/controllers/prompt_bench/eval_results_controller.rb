module PromptBench
  class EvalResultsController < ApplicationController
    include PromptScoped

    before_action :set_eval_result, only: %i[ show destroy ]

    # GET /prompts/:prompt_id/eval_results
    def index
      @eval_results = Page.new @prompt.eval_results, page: params[:page].to_i
    end

    # GET /prompts/:prompt_id/eval_results/1
    def show
    end

    # POST /prompts/:prompt_id/eval_results
    def create
      EvalPromptJob.perform_later prompt_id: @prompt.id
      redirect_to prompt_eval_results_path(@prompt), notice: "Prompt is being evaluated."
    end

    # DELETE /prompts/:prompt_id/eval_results/:id
    def destroy
      @eval_result.destroy!
      redirect_to prompt_eval_results_path(@prompt), notice: "Eval result was successfully destroyed.", status: :see_other
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_eval_result
        @eval_result = @prompt.eval_results.find(params.expect(:id))
      end
  end
end
