module ActiveModel
  module Validations
    class ToolsValidator < JsonArrayValidator
      def validate_each(record, attribute, value)
        return if value.blank?

        super

        return unless record.send(:"#{attribute}").is_a?(Array)

        undefined_tools = record.send(:"#{attribute}").reject do |tool_name|
          tool_name.constantize
        rescue NameError
        end

        record.errors.add(attribute, "#{undefined_tools.to_sentence} are not defined") if undefined_tools.any?
      end
    end
  end
end
