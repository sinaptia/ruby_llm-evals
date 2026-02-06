module RubyLLM
  module Evals
    module PromptsHelper
      def models_by_provider_data
        @models_by_provider_data ||= RubyLLM.models.group_by(&:provider).transform_values { |models| models.map { |m| { id: m.id, name: m.name } } }.to_json
      end

      def available_tools
        Rails.application.eager_load! unless Rails.application.config.eager_load
        RubyLLM::Tool.descendants.map(&:name).uniq.sort
      end

      def available_schemas
        Rails.application.eager_load! unless Rails.application.config.eager_load
        RubyLLM::Schema.descendants.map(&:name).reject { |name| name.start_with? "RubyLLM::Evals::" }.uniq.sort
      end

      def schema_options_for_select(prompt)
        options = available_schemas.map { |s| [ s, s ] } + [ [ "Other", "" ] ]

        # Determine what should be selected:
        # * If schema is present and in available schemas, select it
        # * If schema is blank but schema_other is present, select "Other" (empty string)
        # * Otherwise, select nothing (nil)
        selected = if prompt.schema.present? && available_schemas.include?(prompt.schema)
          prompt.schema
        elsif prompt.schema.blank? && prompt.schema_other.present?
          ""
        else
          nil
        end

        options_for_select(options, selected)
      end
    end
  end
end
