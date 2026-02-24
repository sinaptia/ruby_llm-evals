module RubyLLM
  module Evals
    class Run
      module Pinnable
      extend ActiveSupport::Concern

      included do
        scope :pinned, -> { where.not(pinned_at: nil) }
      end

      def pinned?
        pinned_at.present?
      end

      def pin!
        transaction do
          prompt.runs.where.not(id: id).pinned.update_all(pinned_at: nil)
          update!(pinned_at: Time.current)
        end
      end

      def unpin!
        update!(pinned_at: nil)
      end
      end
    end
  end
end
