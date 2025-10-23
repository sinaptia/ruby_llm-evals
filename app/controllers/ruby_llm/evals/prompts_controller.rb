module RubyLLM
  module Evals
    class PromptsController < ApplicationController
      before_action :set_prompt, only: %i[ show edit update destroy ]

      def index
        @prompts = Page.new Prompt.all, page: params[:page].to_i
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

      private

      def set_prompt
        @prompt = Prompt.find(params[:id])
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
          samples_attributes: [ :id, :_destroy, :eval_type, :expected_output, :variables, files: [] ],
          tools: []
        ).tap do |prompt_params|
          prompt_params[:tools].try(:reject!, &:blank?)
        end
      end
    end
  end
end
