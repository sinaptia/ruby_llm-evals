module RubyLLM
  module Evals
    class RunsController < ApplicationController
      before_action :set_run, only: %i[show destroy]
      before_action :set_filters, only: %i[index]
      before_action :set_prompt, only: %i[create]

      def index
        @runs = Page.new Run.where(@filters), page: params[:page].to_i
      end

      def show
      end

      def create
        PerformRunJob.perform_later prompt_id: @prompt.id
        redirect_to runs_path(filter: { ruby_llm_evals_prompt_id: @prompt.id }), notice: "Prompt is being evaluated."
      end

      def destroy
        @run.destroy!
        redirect_to prompt_runs_path(@run.prompt), notice: "Run was successfully destroyed.", status: :see_other
      end

      private

      def filter_param
        { filter: @filters }
      end
      helper_method :filter_param

      def set_run
        @run = Run.find params[:id]
      end

      def set_filters
        @filters = {
          ruby_llm_evals_prompt_id: params.dig(:filter, :ruby_llm_evals_prompt_id).presence
        }.compact
      end

      def set_prompt
        @prompt = Prompt.find params[:prompt_id]
      end
    end
  end
end
