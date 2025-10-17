module ActiveModel
  module Validations
    class JsonArrayValidator < JsonValidator
      def validate_each(record, attribute, value)
        return if value.blank?

        super

        record.errors.add(attribute, :must_be_json_array) unless record.send(:"#{attribute}").is_a?(Array)
      end
    end
  end
end
