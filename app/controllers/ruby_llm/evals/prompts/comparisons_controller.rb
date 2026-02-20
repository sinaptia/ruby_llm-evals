module RubyLLM
  module Evals
    module Prompts
      class ComparisonsController < ApplicationController
        before_action :set_prompt

        def show
          @runs = @prompt.runs.includes(prompt_executions: :sample).order(created_at: :asc)
          @samples = @prompt.samples.order(id: :asc)
        end

        private

        def set_prompt
          @prompt = Prompt.find(params[:prompt_id])
        end
      end
    end
  end
end
