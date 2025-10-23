require "test_helper"

module RubyLLM
  module Evals
    class PromptExecutionsControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers

      setup do
        @prompt_execution = ruby_llm_evals_prompt_executions(:one)
      end

      test "should toggle prompt_execution passed status" do
        patch toggle_prompt_execution_url(@prompt_execution)
        assert_redirected_to run_url(@prompt_execution.run)

        @prompt_execution.reload
        assert_equal false, @prompt_execution.passed
      end
    end
  end
end
