require "test_helper"

module RubyLLM
  module Evals
    class PromptExecutionsControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers

      setup do
        @human_execution = ruby_llm_evals_prompt_executions(:four)
      end

      test "marks unevaluated execution as passed" do
        assert_changes -> { @human_execution.reload.passed }, from: nil, to: true do
          patch pass_prompt_execution_url(@human_execution)
        end

        assert_redirected_to run_url(@human_execution.run)
      end

      test "marks unevaluated execution as failed" do
        assert_changes -> { @human_execution.reload.passed }, from: nil, to: false do
          patch fail_prompt_execution_url(@human_execution)
        end

        assert_redirected_to run_url(@human_execution.run)
      end

      test "changes failed execution to passed when using pass action" do
        @human_execution.update!(passed: false)

        assert_changes -> { @human_execution.reload.passed }, from: false, to: true do
          patch pass_prompt_execution_url(@human_execution)
        end

        assert_redirected_to run_url(@human_execution.run)
      end

      test "changes passed execution to failed when using fail action" do
        @human_execution.update!(passed: true)

        assert_changes -> { @human_execution.reload.passed }, from: true, to: false do
          patch fail_prompt_execution_url(@human_execution)
        end

        assert_redirected_to run_url(@human_execution.run)
      end
    end
  end
end
