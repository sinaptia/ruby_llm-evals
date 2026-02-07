require "test_helper"

module RubyLLM
  module Evals
    module PromptExecutions
      class FailuresControllerTest < ActionDispatch::IntegrationTest
        include Engine.routes.url_helpers

        setup do
          @human_execution = ruby_llm_evals_prompt_executions(:four)
        end

        test "marks unevaluated execution as failed" do
          assert_changes -> { @human_execution.reload.passed }, from: nil, to: false do
            post prompt_execution_failure_url(@human_execution)
          end

          assert_redirected_to run_url(@human_execution.run)
        end

        test "changes passed execution to failed" do
          @human_execution.update!(passed: true)

          assert_changes -> { @human_execution.reload.passed }, from: true, to: false do
            post prompt_execution_failure_url(@human_execution)
          end

          assert_redirected_to run_url(@human_execution.run)
        end
      end
    end
  end
end
