module PromptBench
  module PromptScoped
    extend ActiveSupport::Concern

    included do
      before_action :set_prompt
    end

    def set_prompt
      @prompt = Prompt.find params.expect(:prompt_id)
    end
  end
end
