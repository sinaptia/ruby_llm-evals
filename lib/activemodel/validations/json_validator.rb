module ActiveModel
  module Validations
    class JsonValidator < EachValidator
      def validate_each(record, attribute, value)
        return if value.blank?
        return unless value.is_a? String

        record.send :"#{attribute}=", JSON.parse(value)
      rescue JSON::ParserError
        record.errors.add attribute, :invalid_json
      end
    end
  end
end
