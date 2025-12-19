module RubyLLM
  module Evals
    class JudgeVerdictSchema < RubyLLM::Schema
      boolean :passed, description: "Whether the output correctly fulfills the task"
      string :explanation, description: "Brief explanation of the verdict"
    end
  end
end
