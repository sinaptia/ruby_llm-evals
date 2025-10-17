module ActiveModel
  module Validations
    class JsonObjectValidator < JsonValidator
      def validate_each(record, attribute, value)
        return if value.blank?

        super

        record.errors.add(attribute, :must_be_json_object) unless record.send(:"#{attribute}").is_a?(Hash)
      end
    end
  end
end
