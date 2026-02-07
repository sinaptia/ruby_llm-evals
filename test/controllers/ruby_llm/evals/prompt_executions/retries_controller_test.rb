require "test_helper"

module RubyLLM
  module Evals
    module PromptExecutions
      class RetriesControllerTest < ActionDispatch::IntegrationTest
        include Engine.routes.url_helpers

        setup do
          @human_execution = ruby_llm_evals_prompt_executions(:four)
        end

        test "retries the prompt execution" do
          # Stub the retry_job method to avoid actual job retry logic
          def @human_execution.retry_job
            nil
          end
          post prompt_execution_retry_url(@human_execution)
          assert_redirected_to run_url(@human_execution.run)
        end

        test "handles retry errors gracefully" do
          post prompt_execution_retry_url(@human_execution)
          assert_redirected_to run_url(@human_execution.run)
          assert_match(/Failed to retry:/, flash[:alert])
        end
      end
    end
  end
end
