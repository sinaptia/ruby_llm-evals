module RubyLLM
  module Evals
    module ApplicationHelper
      def duration(obj)
        return "N/A" unless obj.finished?

        distance_of_time_in_words obj.started_at, obj.ended_at, include_seconds: true
      end

      def expected_output(obj)
        if obj.regex?
          content_tag :code, "/#{obj.expected_output}/i"
        else
          obj.expected_output
        end
      end

      def json(hash)
        if hash.present?
          content_tag :pre, JSON.pretty_generate(hash)
        end
      end
    end
  end
end
