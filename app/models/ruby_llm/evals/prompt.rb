module RubyLLM
  module Evals
    class Prompt < ApplicationRecord
      include Executable

      has_many :samples, class_name: "RubyLLM::Evals::Sample", foreign_key: :ruby_llm_evals_prompt_id, inverse_of: :prompt, dependent: :destroy
      has_many :runs, class_name: "RubyLLM::Evals::Run", foreign_key: :ruby_llm_evals_prompt_id, dependent: :destroy
      has_one :pinned_run, -> { where.not(pinned_at: nil) }, class_name: "RubyLLM::Evals::Run", foreign_key: :ruby_llm_evals_prompt_id

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
        if pinned_run.present?
          pinned_run.execute(variables: variables, files: files)
        else
          super
        end
      end

      private

      def set_slug
        self.slug = name&.parameterize
      end
    end
  end
end
