module RubyLLM
  module Evals
    class Prompt < ApplicationRecord
      has_many :samples, class_name: "RubyLLM::Evals::Sample", foreign_key: :ruby_llm_evals_prompt_id, inverse_of: :prompt, dependent: :destroy
      has_many :runs, class_name: "RubyLLM::Evals::Run", foreign_key: :ruby_llm_evals_prompt_id, dependent: :destroy

      accepts_nested_attributes_for :samples, reject_if: :all_blank, allow_destroy: true

      validates :message, presence: true
      validates :model, presence: true
      validates :name, presence: true, uniqueness: true
      validates :params, json: true
      validates :provider, presence: true
      validates :schema_other, json: true
      validates :slug, presence: true, uniqueness: true

      normalizes :params, :tools, :schema_other, with: ->(value) { value.blank? ? nil : value }

      before_validation :set_slug

      def self.execute(slug, variables: {}, files: [])
        prompt = find_by!(slug: slug)
        prompt.execute(variables: variables, files: files)
      end

      def execute(variables: {}, files: [])
        chat = RubyLLM.chat(model: model, provider: provider)

        chat.with_instructions Liquid::Template.parse(instructions).render(variables) if instructions.present?

        chat.with_temperature(temperature) if temperature.present?
        chat.with_params(**params) if params.present?

        if tools.present?
          tool_classes = tools.map { _1.constantize rescue nil }.compact
          chat.with_tools(*tool_classes)
        end

        if schema_other.present?
          chat.with_schema(**schema_other)
        elsif schema.present?
          chat.with_schema schema.constantize
        end

        chat.with_thinking(effort: thinking_effort) if thinking_effort.present?
        chat.with_thinking(budget: thinking_budget) if thinking_budget.present?

        chat.ask Liquid::Template.parse(message).render(variables), with: files
      end

      private

      def set_slug
        self.slug = name&.parameterize
      end
    end
  end
end
