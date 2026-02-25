module RubyLLM
  module Evals
    class PromptExecution < ApplicationRecord
      include PromptExecution::JobRetryable
      include JobTrackable

      JUDGE_PROMPT_TEMPLATE = <<~TEMPLATE.freeze
        You are an expert evaluator. Determine if the output correctly fulfills the task.

        ## Task Given
        {{rendered_message}}

        ## Output to Evaluate
        {{output}}

        ## Evaluation Criteria
        {{criteria}}

        Return whether the output PASSED or FAILED based on the criteria.
      TEMPLATE

      belongs_to :sample, class_name: "RubyLLM::Evals::Sample", foreign_key: :ruby_llm_evals_sample_id
      belongs_to :run, class_name: "RubyLLM::Evals::Run", foreign_key: :ruby_llm_evals_run_id

      has_many_attached :files

      enum :eval_type, %w[exact contains regex human_judge llm_judge].index_by(&:itself)

      validates :eval_type, presence: true
      validates :expected_output, presence: true, unless: :human_judge?

      normalizes :judge_message, with: ->(value) { value.blank? ? nil : value }
      normalizes :variables, with: ->(value) { value.blank? ? nil : value }

      before_validation :set_sample_attributes, on: :create

      def cost
        calculate_cost(
          model_name: run.model,
          provider_name: run.provider,
          input_tokens: input,
          output_tokens: output,
          thinking_tokens: thinking
        )
      end

      def judge_cost
        return 0.0 if judge_model.blank?

        calculate_cost(
          model_name: judge_model,
          provider_name: judge_provider,
          input_tokens: judge_input,
          output_tokens: judge_output,
          thinking_tokens: judge_thinking
        )
      end

      def total_cost
        (cost + judge_cost).round(4)
      end

      def execute
        response = run.execute(
          variables: variables,
          files: files.map(&:blob)
        )

        message = response.content.is_a?(Hash) ? response.content.to_json : response.content.chomp

        passed = case eval_type
        when "contains" then message.include?(expected_output)
        when "exact" then message == expected_output
        when "regex" then Regexp.new(expected_output, "i").match?(message)
        when "llm_judge" then judge(message)
        end

        update(
          input: response.input_tokens,
          output: response.output_tokens,
          thinking: response.thinking_tokens,
          message:,
          passed:
        )
      end

      private

      def calculate_cost(model_name:, provider_name:, input_tokens:, output_tokens:, thinking_tokens:)
        return 0.0 if [ input_tokens, output_tokens ].all?(nil)

        model, provider = RubyLLM.models.resolve(model_name, provider: provider_name)
        return 0.0 if provider.nil? || provider.local?

        input_cost = input_tokens.to_f / 1_000_000.0 * model.input_price_per_million
        output_cost = output_tokens.to_f / 1_000_000.0 * model.output_price_per_million
        thinking_cost = thinking_tokens.to_f / 1_000_000.0 * model.output_price_per_million

        (input_cost + output_cost + thinking_cost).round(4)
      end

      def judge(output)
        rendered_message = Liquid::Template.parse(run.message).render(variables)

        chat = RubyLLM.chat(model: judge_model, provider: judge_provider).with_schema(JudgeVerdictSchema)

        judge_prompt = Liquid::Template.parse(JUDGE_PROMPT_TEMPLATE).render(
          "rendered_message" => rendered_message,
          "output" => output,
          "criteria" => expected_output
        )

        judge_response = chat.ask(judge_prompt)
        verdict = judge_response.content

        assign_attributes(
          judge_message: verdict,
          judge_input: judge_response.input_tokens,
          judge_output: judge_response.output_tokens,
          judge_thinking: judge_response.thinking_tokens
        )

        verdict["passed"]
      end

      def set_sample_attributes
        %i[eval_type expected_output judge_model judge_provider variables].each do |attribute|
          send(:"#{attribute}=", sample.send(:"#{attribute}"))
        end

        sample.files.each { |file| files.attach file.blob }
      end
    end
  end
end
