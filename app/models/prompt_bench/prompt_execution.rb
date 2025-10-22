module PromptBench
  class PromptExecution < ApplicationRecord
    belongs_to :sample, foreign_key: :prompt_bench_sample_id
    belongs_to :eval_result, foreign_key: :prompt_bench_eval_result_id

    has_many_attached :files

    enum :eval_type, %w[exact contains regex human].index_by(&:itself)

    validates :eval_type, presence: true
    validates :expected_output, presence: true, unless: ->(sample) { sample.human? }

    normalizes :variables, with: ->(value) { value.blank? ? nil : value }

    before_validation :set_sample_attributes, on: :create

    def self.execute(sample:, eval_result:)
      prompt_execution = create(sample:, eval_result:)

      response = sample.prompt.execute(
        variables: prompt_execution.variables,
        files: prompt_execution.files.map(&:blob)
      )

      message = response.content.is_a?(Hash) ? response.content.to_json : response.content.chomp

      passed = case prompt_execution.eval_type
      when "contains" then message.include?(prompt_execution.expected_output)
      when "exact" then message == prompt_execution.expected_output
      when "regex" then Regexp.new(prompt_execution.expected_output, "i").match?(message)
      end

      prompt_execution.update(
        input: response.input_tokens,
        output: response.output_tokens,
        message:,
        passed:
      )
    end

    def cost
      model, provider = RubyLLM.models.resolve eval_result.model, provider: eval_result.provider

      return 0.0 if provider.local? || [ input, output ].all?(nil)

      input_cost = input / 1_000_000.0 * model.input_price_per_million
      output_cost = output / 1_000_000.0 * model.output_price_per_million

      (input_cost + output_cost).round(4)
    end

    private

    def set_sample_attributes
      %i[eval_type expected_output variables].each { |attribute| send :"#{attribute}=", sample.send(:"#{attribute}") }

      sample.files.each { |file| files.attach file.blob }
    end
  end
end
