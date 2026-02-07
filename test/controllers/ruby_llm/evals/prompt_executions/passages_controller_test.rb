require "test_helper"

module RubyLLM
  module Evals
    module PromptExecutions
      class PassagesControllerTest < ActionDispatch::IntegrationTest
        include Engine.routes.url_helpers

        setup do
          @human_execution = ruby_llm_evals_prompt_executions(:four)
        end

        test "marks unevaluated execution as passed" do
          assert_changes -> { @human_execution.reload.passed }, from: nil, to: true do
            post prompt_execution_passage_url(@human_execution)
          end

          assert_redirected_to run_url(@human_execution.run)
        end

        test "changes failed execution to passed" do
          @human_execution.update!(passed: false)

          assert_changes -> { @human_execution.reload.passed }, from: false, to: true do
            post prompt_execution_passage_url(@human_execution)
          end

          assert_redirected_to run_url(@human_execution.run)
        end
      end
    end
  end
end
