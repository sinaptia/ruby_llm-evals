module RubyLLM
  module Evals
    module RunsHelper
      def accuracy(run)
        run.finished? ? "#{run.accuracy}%" : "N/A"
      end

      def duration(run)
        return "N/A" unless run.finished?

        distance_of_time_in_words run.started_at, run.ended_at, include_seconds: true
      end
    end
  end
end
