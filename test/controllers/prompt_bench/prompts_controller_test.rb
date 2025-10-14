require "test_helper"

module PromptBench
  class PromptsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @prompt = prompt_bench_prompts(:one)
    end

    test "should get index" do
      get prompts_url
      assert_response :success
    end

    test "should get new" do
      get new_prompt_url
      assert_response :success
    end

    test "should create prompt" do
      assert_difference("Prompt.count") do
        post prompts_url, params: { prompt: { instructions: @prompt.instructions, message: @prompt.message, model: @prompt.model, name: @prompt.name, provider: @prompt.provider, slug: @prompt.slug } }
      end

      assert_redirected_to prompt_url(Prompt.last)
    end

    test "should show prompt" do
      get prompt_url(@prompt)
      assert_response :success
    end

    test "should get edit" do
      get edit_prompt_url(@prompt)
      assert_response :success
    end

    test "should update prompt" do
      patch prompt_url(@prompt), params: { prompt: { instructions: @prompt.instructions, message: @prompt.message, model: @prompt.model, name: @prompt.name, provider: @prompt.provider, slug: @prompt.slug } }
      assert_redirected_to prompt_url(@prompt)
    end

    test "should destroy prompt" do
      assert_difference("Prompt.count", -1) do
        delete prompt_url(@prompt)
      end

      assert_redirected_to prompts_url
    end
  end
end
