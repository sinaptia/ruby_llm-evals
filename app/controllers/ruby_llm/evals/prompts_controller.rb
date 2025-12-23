module RubyLLM
  module Evals
    class PromptsController < ApplicationController
      before_action :set_filters, only: %i[ index ]
      before_action :set_prompt, only: %i[ show edit update destroy compare ]

      def index
        prompts = Prompt.all
        prompts = prompts.where("name LIKE ?", "%#{Prompt.sanitize_sql_like(@filters[:name])}%") if @filters[:name].present?
        @prompts = Page.new prompts, page: params[:page].to_i
      end

      def show
      end

      def new
        @prompt = Prompt.new
      end

      def edit
      end

      def create
        @prompt = Prompt.new(prompt_params)

        if @prompt.save
          redirect_to @prompt, notice: "Prompt was successfully created."
        else
          render :new, status: :unprocessable_entity
        end
      end

      def update
        if @prompt.update(prompt_params)
          redirect_to @prompt, notice: "Prompt was successfully updated.", status: :see_other
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @prompt.destroy!
        redirect_to prompts_path, notice: "Prompt was successfully destroyed.", status: :see_other
      end

      def compare
        @runs = @prompt.runs.includes(prompt_executions: :sample).order(created_at: :asc)
        @samples = @prompt.samples.order(id: :asc)
      end

      private

      def filter_param
        { filter: @filters }
      end

      def prompt_params
        params.require(:prompt).permit(
          :name,
          :slug,
          :provider,
          :model,
          :temperature,
          :params,
          :instructions,
          :message,
          :schema,
          :schema_other,
          samples_attributes: [ :id, :_destroy, :eval_type, :expected_output, :judge_model, :judge_provider, :variables, files: [] ],
          tools: []
        ).tap do |prompt_params|
          prompt_params[:tools].try(:reject!, &:blank?)
        end
      end

      def set_filters
        @filters = {
          name: params.dig(:filter, :name).presence
        }.compact
      end

      def set_prompt
        @prompt = Prompt.find(params[:id])
      end
    end
  end
end
