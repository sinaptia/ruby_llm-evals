module PromptBench
  class Prompt < ApplicationRecord
    has_many :eval_examples, foreign_key: :prompt_bench_prompt_id, inverse_of: :prompt, dependent: :destroy
    has_many :eval_results, foreign_key: :prompt_bench_prompt_id, dependent: :destroy

    accepts_nested_attributes_for :eval_examples, reject_if: :all_blank, allow_destroy: true

    validates :message, presence: true
    validates :model, presence: true
    validates :name, presence: true, uniqueness: true
    validates :params, json: true
    validates :provider, presence: true
    validates :slug, presence: true, uniqueness: true

    before_validation :set_slug

    def self.execute(slug, variables: {}, files: [])
      prompt = find_by!(slug: slug)
      prompt.execute(variables: variables, files: files)
    end

    def execute(variables: {}, files: [])
      message_text = substitute_variables(message, variables)
      instructions_text = substitute_variables(instructions, variables) if instructions.present?

      chat = RubyLLM.chat(model: model, provider: provider)
      chat.with_instructions(instructions_text) if instructions_text.present?
      chat.with_temperature(temperature) if temperature.present?
      chat.with_params(**params) if params.present?

      if tools.present?
        tool_classes = tools.map { _1.constantize rescue nil }.compact
        chat.with_tools(*tool_classes)
      end

      chat.ask(message_text, with: files)
    end

    private

    def set_slug
      self.slug = name&.parameterize
    end

    def substitute_variables(text, variables)
      return text if text.blank? || variables.blank?

      text.dup.tap do |result|
        variables.each { |k, v| result.gsub!("{{#{k}}}", v.to_s) }
      end
    end
  end
end
