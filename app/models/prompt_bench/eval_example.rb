module PromptBench
  class EvalExample < ApplicationRecord
    belongs_to :prompt, foreign_key: :prompt_bench_prompt_id, inverse_of: :eval_examples
    has_many :prompt_executions, foreign_key: :prompt_bench_eval_example_id, dependent: :destroy

    has_many_attached :files

    enum :eval_type, %w[exact contains regex human].index_by(&:itself)

    validates :eval_type, presence: true
    validates :expected_output, presence: true, unless: ->(eval_example) { eval_example.human? }

    def variables=(value)
      parsed_value = if value.is_a?(String) && value.present?
        JSON.parse(value)
      else
        value
      end
      super(parsed_value)
    rescue JSON::ParserError
      super(value)
    end
  end
end
