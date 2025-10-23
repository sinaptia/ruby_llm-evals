module RubyLLM
  module Evals
    class Sample < ApplicationRecord
      belongs_to :prompt, class_name: "RubyLLM::Evals::Prompt", foreign_key: :ruby_llm_evals_prompt_id, inverse_of: :samples
      has_many :prompt_executions, class_name: "RubyLLM::Evals::PromptExecution", foreign_key: :ruby_llm_evals_sample_id, dependent: :destroy

      has_many_attached :files

      enum :eval_type, %w[exact contains regex human].index_by(&:itself)

      validates :eval_type, presence: true
      validates :expected_output, presence: true, unless: ->(sample) { sample.human? }
      validates :variables, json: true

      normalizes :variables, with: ->(value) { value.blank? ? nil : value }
    end
  end
end
