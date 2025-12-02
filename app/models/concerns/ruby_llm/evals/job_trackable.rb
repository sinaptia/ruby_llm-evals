module RubyLLM
  module Evals
    module JobTrackable
      extend ActiveSupport::Concern

      included do
        validates :active_job_id, presence: true
      end

      def finished?
        ended_at.present?
      end
    end
  end
end
