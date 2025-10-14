require "test_helper"

module PromptBench
  class EvalResultsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @eval_result = prompt_bench_eval_results(:one)
      @prompt = @eval_result.prompt
    end

    test "should get index" do
      get prompt_eval_results_url(@prompt)
      assert_response :success
    end

    test "should get new" do
      get new_prompt_eval_result_url(@prompt)
      assert_response :success
    end

    test "should create eval_result" do
      assert_difference("EvalResult.count") do
        post prompt_eval_results_url(@prompt), params: { eval_result: { ended_at: @eval_result.ended_at, prompt_id: @eval_result.prompt_id, started_at: @eval_result.started_at } }
      end

      assert_redirected_to prompt_eval_result_url(@prompt, EvalResult.last)
    end

    test "should show eval_result" do
      get prompt_eval_result_url(@prompt, @eval_result)
      assert_response :success
    end

    test "should get edit" do
      get edit_prompt_eval_result_url(@prompt, @eval_result)
      assert_response :success
    end

    test "should update eval_result" do
      patch prompt_eval_result_url(@prompt, @eval_result), params: { eval_result: { ended_at: @eval_result.ended_at, prompt_id: @eval_result.prompt_id, started_at: @eval_result.started_at } }
      assert_redirected_to prompt_eval_result_url(@prompt, @eval_result)
    end

    test "should destroy eval_result" do
      assert_difference("EvalResult.count", -1) do
        delete prompt_eval_result_url(@prompt, @eval_result)
      end

      assert_redirected_to prompt_eval_results_url(@prompt)
    end
  end
end
