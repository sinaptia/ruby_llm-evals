require "test_helper"

module PromptBench
  class RunsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @run = prompt_bench_runs(:one)
    end

    test "should get index" do
      get runs_url
      assert_response :success
    end

    test "should show run" do
      get run_url(@run)
      assert_response :success
    end

    test "should enqueue job when creating run via nested route" do
      assert_enqueued_with(job: EvalPromptJob) do
        post prompt_runs_url(@run.prompt)
      end

      assert_redirected_to runs_path(filter: { prompt_bench_prompt_id: @run.prompt.id })
    end

    test "should destroy run" do
      assert_difference("Run.count", -1) do
        delete run_url(@run)
      end

      assert_redirected_to prompt_runs_url(@run.prompt)
    end
  end
end
