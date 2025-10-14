module PromptBench
  module EvalResultScoped
    extend ActiveSupport::Concern

    included do
      before_action :set_eval_result
    end

    def set_eval_result
      @eval_result = EvalResult.find params.expect(:eval_result_id)
    end
  end
end
