module PromptBench
  module PromptsHelper
    def models_by_provider_data
      @models_by_provider_data ||= RubyLLM.models.group_by(&:provider).transform_values { |models| models.map { |m| { id: m.id, name: m.name } } }.to_json
    end

    def available_tools
      Rails.application.eager_load! unless Rails.application.config.eager_load
      RubyLLM::Tool.descendants.map(&:name).uniq.sort
    end
  end
end
