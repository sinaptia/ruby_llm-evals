require "test_helper"

module PromptBench
  class PromptExecutionsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @prompt_execution = prompt_bench_prompt_executions(:one)
    end

    test "should get index" do
      get prompt_executions_url
      assert_response :success
    end

    test "should get new" do
      get new_prompt_execution_url
      assert_response :success
    end

    test "should create prompt_execution" do
      assert_difference("PromptExecution.count") do
        post prompt_executions_url, params: { prompt_execution: {} }
      end

      assert_redirected_to prompt_execution_url(PromptExecution.last)
    end

    test "should show prompt_execution" do
      get prompt_execution_url(@prompt_execution)
      assert_response :success
    end

    test "should get edit" do
      get edit_prompt_execution_url(@prompt_execution)
      assert_response :success
    end

    test "should update prompt_execution" do
      patch prompt_execution_url(@prompt_execution), params: { prompt_execution: {} }
      assert_redirected_to prompt_execution_url(@prompt_execution)
    end

    test "should destroy prompt_execution" do
      assert_difference("PromptExecution.count", -1) do
        delete prompt_execution_url(@prompt_execution)
      end

      assert_redirected_to prompt_executions_url
    end
  end
end
