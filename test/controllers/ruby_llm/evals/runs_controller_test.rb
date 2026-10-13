require "test_helper"

module RubyLLM
  module Evals
    class RunsControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers

      setup do
        @run = ruby_llm_evals_runs(:one)
      end

      test "should get index" do
        get runs_url
        assert_response :success
      end

      test "should show run" do
        get run_url(@run)
        assert_response :success
      end

      test "should show run and index when the model is not in the registry" do
        @run.update_columns(model: "gemini-model-that-does-not-exist")

        get run_url(@run)
        assert_response :success

        get runs_url
        assert_response :success
      end

      test "should show run and index when the judge model is not in the registry" do
        execution = ruby_llm_evals_prompt_executions(:one)
        execution.update_columns(judge_model: "gemini-judge-that-does-not-exist", judge_provider: "gemini", judge_input: 500, judge_output: 50)

        get run_url(@run)
        assert_response :success

        get runs_url
        assert_response :success
      end

      test "should enqueue job when creating run via nested route" do
        assert_enqueued_with(job: PerformRunJob) do
          post prompt_runs_url(@run.prompt)
        end

        assert_redirected_to runs_path(filter: { ruby_llm_evals_prompt_id: @run.prompt.id })
      end

      test "should destroy run" do
        assert_difference("Run.count", -1) do
          delete run_url(@run)
        end

        assert_redirected_to prompt_runs_url(@run.prompt)
      end
    end
  end
end
