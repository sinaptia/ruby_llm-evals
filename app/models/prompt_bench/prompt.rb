module PromptBench
  class Prompt < ApplicationRecord
    has_many :eval_examples, foreign_key: :prompt_bench_prompt_id, inverse_of: :prompt, dependent: :destroy
    has_many :eval_results, foreign_key: :prompt_bench_prompt_id, dependent: :destroy

    accepts_nested_attributes_for :eval_examples, reject_if: :all_blank, allow_destroy: true

    validates :message, presence: true
    validates :model, presence: true
    validates :name, presence: true, uniqueness: true
    validates :provider, presence: true
    validates :slug, presence: true, uniqueness: true

    before_validation :set_slug

    def to_chat
      RubyLLM.chat(model:, provider:).tap do |chat|
        chat.with_instructions(instructions) if instructions.present?
      end
    end

    private

    def set_slug
      self.slug = name.try &:parameterize
    end
  end
end
