module PromptBench
  class PromptExecutor
    def self.execute(slug, variables: {}, files: [])
      prompt = Prompt.find_by!(slug: slug)

      message = substitute_variables(prompt.message, variables)
      instructions = substitute_variables(prompt.instructions, variables) if prompt.instructions.present?

      chat = RubyLLM.chat(model: prompt.model, provider: prompt.provider)
      chat.with_instructions(instructions) if instructions.present?

      chat.ask(message, with: files)
    end

    private_class_method def self.substitute_variables(text, variables)
      return text if text.blank? || variables.blank?

      text.dup.tap do |result|
        variables.each { |k, v| result.gsub!("{{#{k}}}", v.to_s) }
      end
    end
  end
end
