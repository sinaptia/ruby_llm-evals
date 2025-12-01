module RubyLLM
  module Evals
    module ApplicationHelper
      def json(hash)
        if hash.present?
          content_tag :pre, JSON.pretty_generate(hash)
        end
      end
    end
  end
end
