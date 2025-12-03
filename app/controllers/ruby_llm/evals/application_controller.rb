module RubyLLM
  module Evals
    class ApplicationController < ActionController::Base
      layout "ruby_llm/evals/application"

      private

      def filter_param
        {}
      end
      helper_method :filter_param
    end
  end
end
