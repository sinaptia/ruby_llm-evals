module PromptBench
  class PromptExecution < ApplicationRecord
    belongs_to :eval_example, foreign_key: :prompt_bench_eval_example_id
    belongs_to :eval_result, foreign_key: :prompt_bench_eval_result_id

    has_many_attached :files

    enum :eval_type, %w[exact contains regex human].index_by(&:itself)

    validates :eval_type, presence: true
    validates :expected_output, presence: true, unless: ->(eval_example) { eval_example.human? }

    before_validation :set_eval_example_attributes, on: :create

    def self.execute(eval_example:, eval_result:)
      prompt_execution = create(eval_example:, eval_result:)

      response = eval_example.prompt.execute(
        variables: prompt_execution.variables,
        files: prompt_execution.files.map(&:blob)
      )

      passed = case prompt_execution.eval_type
      when "contains" then response.content.chomp.include?(prompt_execution.expected_output)
      when "exact" then response.content.chomp == prompt_execution.expected_output
      when "regex" then Regexp.new(prompt_execution.expected_output, "i").match?(response.content.chomp)
      end

      prompt_execution.update(
        input: response.input_tokens,
        output: response.output_tokens,
        message: response.content.chomp,
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

    def set_eval_example_attributes
      %i[eval_type expected_output variables].each { |attribute| send :"#{attribute}=", eval_example.send(:"#{attribute}") }

      eval_example.files.each { |file| files.attach file.blob }
    end
  end
end
