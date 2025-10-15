require "test_helper"

module PromptBench
  class EvalResultsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @eval_result = prompt_bench_eval_results(:one)
    end

    test "should get index" do
      get eval_results_url
      assert_response :success
    end

    test "should show eval_result" do
      get eval_result_url(@eval_result)
      assert_response :success
    end

    test "should enqueue job when creating eval_result via nested route" do
      assert_enqueued_with(job: EvalPromptJob) do
        post prompt_eval_results_url(@eval_result.prompt)
      end

      assert_redirected_to eval_results_path(filter: { prompt_bench_prompt_id: @eval_result.prompt.id })
    end

    test "should destroy eval_result" do
      assert_difference("EvalResult.count", -1) do
        delete eval_result_url(@eval_result)
      end

      assert_redirected_to prompt_eval_results_url(@eval_result.prompt)
    end
  end
end
