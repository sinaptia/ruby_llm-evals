require "test_helper"

module RubyLLM
  module Evals
    class PromptsControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers

      setup do
        @prompt = ruby_llm_evals_prompts(:one)
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
          post prompts_url, params: { prompt: { instructions: @prompt.instructions, message: @prompt.message, model: @prompt.model, name: "Unique Test Prompt", provider: @prompt.provider } }
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
        patch prompt_url(@prompt), params: { prompt: { instructions: @prompt.instructions, message: @prompt.message, model: @prompt.model, name: @prompt.name, provider: @prompt.provider } }
        assert_redirected_to prompt_url(@prompt)
      end

      test "should destroy prompt" do
        assert_difference("Prompt.count", -1) do
          delete prompt_url(@prompt)
        end

        assert_redirected_to prompts_url
      end

      test "should not create prompt with missing name" do
        assert_no_difference("Prompt.count") do
          post prompts_url, params: { prompt: { instructions: @prompt.instructions, message: @prompt.message, model: @prompt.model, provider: @prompt.provider } }
        end

        assert_response :unprocessable_entity
      end

      test "should not create prompt with missing message" do
        assert_no_difference("Prompt.count") do
          post prompts_url, params: { prompt: { instructions: @prompt.instructions, name: "Test", model: @prompt.model, provider: @prompt.provider } }
        end

        assert_response :unprocessable_entity
      end

      test "should not create prompt with duplicate name" do
        assert_no_difference("Prompt.count") do
          post prompts_url, params: { prompt: { instructions: @prompt.instructions, message: @prompt.message, model: @prompt.model, name: @prompt.name, provider: @prompt.provider } }
        end

        assert_response :unprocessable_entity
      end

      test "should not update prompt with invalid data" do
        assert_no_changes -> { @prompt.reload.name } do
          patch prompt_url(@prompt), params: { prompt: { name: "" } }
          assert_response :unprocessable_entity
        end
      end

      test "should create prompt with schema" do
        assert_difference("Prompt.count") do
          post prompts_url, params: {
            prompt: {
              name: "Prompt with Schema",
              provider: "anthropic",
              model: "claude-3-5-sonnet-20241022",
              message: "Test message",
              schema: "WeatherSchema"
            }
          }
        end

        assert_equal "WeatherSchema", Prompt.last.schema
        assert_redirected_to prompt_url(Prompt.last)
      end

      test "should create prompt with schema_other" do
        schema_other = { "type" => "object", "properties" => { "name" => { "type" => "string" } } }

        assert_difference("Prompt.count") do
          post prompts_url, params: {
            prompt: {
              name: "Prompt with Schema Other",
              provider: "anthropic",
              model: "claude-3-5-sonnet-20241022",
              message: "Test message",
              schema_other: schema_other.to_json
            }
          }
        end

        assert_equal schema_other, Prompt.last.schema_other
        assert_redirected_to prompt_url(Prompt.last)
      end

      test "should update prompt with schema" do
        patch prompt_url(@prompt), params: {
          prompt: {
            name: @prompt.name,
            provider: @prompt.provider,
            model: @prompt.model,
            message: @prompt.message,
            schema: "UserSchema"
          }
        }

        @prompt.reload
        assert_equal "UserSchema", @prompt.schema
        assert_redirected_to prompt_url(@prompt)
      end

      test "should update prompt with schema_other" do
        schema_other = { "type" => "array", "items" => { "type" => "string" } }

        patch prompt_url(@prompt), params: {
          prompt: {
            name: @prompt.name,
            provider: @prompt.provider,
            model: @prompt.model,
            message: @prompt.message,
            schema_other: schema_other.to_json
          }
        }

        @prompt.reload
        assert_equal schema_other, @prompt.schema_other
        assert_redirected_to prompt_url(@prompt)
      end
    end
  end
end
