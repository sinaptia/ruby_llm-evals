module RubyLLM
  module Evals
    module RunsHelper
      def accuracy(run)
        run.finished? ? "#{run.accuracy}%" : "N/A"
      end
    end
  end
end
