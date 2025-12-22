module RubyLLM
  module Evals
    module ApplicationHelper
      def accuracy(obj)
        obj.finished? ? "#{obj.accuracy}%" : "N/A"
      end

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

      def status_indicator(prompt_execution)
        if prompt_execution.passed.nil?
          content_tag :span, "⏳", title: "Pending or in progress"
        elsif prompt_execution.passed?
          content_tag :span, "🟢", title: "Passed"
        else
          content_tag :span, "🔴", title: "Failed"
        end
      end
    end
  end
end
