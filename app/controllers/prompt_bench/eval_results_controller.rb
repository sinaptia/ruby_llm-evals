module PromptBench
  class EvalResultsController < ApplicationController
    before_action :set_eval_result, only: %i[show destroy]
    before_action :set_filters, only: %i[index]
    before_action :set_prompt, only: %i[create]

    def index
      @eval_results = Page.new EvalResult.where(@filters), page: params[:page].to_i
    end

    def show
    end

    def create
      EvalPromptJob.perform_later prompt_id: @prompt.id
      redirect_to eval_results_path(filter: { prompt_bench_prompt_id: @prompt.id }), notice: "Prompt is being evaluated."
    end

    def destroy
      @eval_result.destroy!
      redirect_to prompt_eval_results_path(@eval_result.prompt), notice: "Eval result was successfully destroyed.", status: :see_other
    end

    private

    def filter_param
      { filter: @filters }
    end
    helper_method :filter_param

    def set_eval_result
      @eval_result = EvalResult.find params.expect(:id)
    end

    def set_filters
      @filters = {
        prompt_bench_prompt_id: params.dig(:filter, :prompt_bench_prompt_id).presence
      }.compact
    end

    def set_prompt
      @prompt = Prompt.find params.expect(:prompt_id)
    end
  end
end
