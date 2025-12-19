module RubyLLM
  module Evals
    class Run < ApplicationRecord
      include JobTrackable

      belongs_to :prompt, class_name: "RubyLLM::Evals::Prompt", foreign_key: :ruby_llm_evals_prompt_id
      has_many :prompt_executions, class_name: "RubyLLM::Evals::PromptExecution", foreign_key: :ruby_llm_evals_run_id, dependent: :destroy

      validates :message, presence: true
      validates :model, presence: true
      validates :provider, presence: true

      normalizes :params, :tools, :schema_other, with: ->(value) { value.blank? ? nil : value }

      before_validation :set_prompt_attributes, on: :create

      scope :finished, -> { where.not(ended_at: nil) }

      def accuracy
        return 0.0 if prompt_executions.none?

        (prompt_executions.where(passed: true).count * 100.0 / prompt_executions.count).round 2
      end

      def cost
        prompt_executions.sum(&:cost).round(4)
      end

      def judge_cost
        prompt_executions.sum(&:judge_cost).round(4)
      end

      def total_cost
        (cost + judge_cost).round(4)
      end

      private

      def set_prompt_attributes
        %i[instructions message model params provider temperature tools schema schema_other].each { |attribute| send :"#{attribute}=", prompt.send(:"#{attribute}") }
      end
    end
  end
end
