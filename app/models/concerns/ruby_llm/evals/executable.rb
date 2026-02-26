module RubyLLM
  module Evals
    module Executable
      extend ActiveSupport::Concern

      def execute(variables: {}, files: [])
        to_chat(variables:, files:).complete
      end

      def to_chat(variables: {}, files: [])
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

        rendered_message = Liquid::Template.parse(message).render(variables)
        content = files.present? ? RubyLLM::Content.new(rendered_message, files) : rendered_message
        chat.add_message role: :user, content: content

        chat
      end
    end
  end
end
