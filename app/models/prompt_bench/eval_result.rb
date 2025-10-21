module PromptBench
  class EvalResult < ApplicationRecord
    belongs_to :prompt, foreign_key: :prompt_bench_prompt_id
    has_many :prompt_executions, foreign_key: :prompt_bench_eval_result_id, dependent: :destroy

    validates :active_job_id, presence: true
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

    def finished?
      ended_at.present?
    end

    private

    def set_prompt_attributes
      %i[instructions message model params provider temperature tools schema schema_other].each { |attribute| send :"#{attribute}=", prompt.send(:"#{attribute}") }
    end
  end
end
