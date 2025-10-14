module PromptBench
  module PromptsHelper
    def models_by_provider_data
      @models_by_provider_data ||= RubyLLM.models.group_by(&:provider).transform_values { |models| models.map { |m| { id: m.id, name: m.name } } }.to_json
    end
  end
end
