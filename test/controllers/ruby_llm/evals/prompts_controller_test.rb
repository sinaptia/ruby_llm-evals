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

      test "should create prompt with thinking_effort" do
        assert_difference("Prompt.count") do
          post prompts_url, params: {
            prompt: {
              name: "Prompt with thinking effort",
              provider: "anthropic",
              model: "claude-3-5-sonnet-20241022",
              message: "Test message",
              thinking_effort: "high"
            }
          }
        end

        assert_equal "high", Prompt.last.thinking_effort
        assert_redirected_to prompt_url(Prompt.last)
      end

      test "should create prompt with thinking_budget" do
        assert_difference("Prompt.count") do
          post prompts_url, params: {
            prompt: {
              name: "Prompt with thinking effort",
              provider: "anthropic",
              model: "claude-3-5-sonnet-20241022",
              message: "Test message",
              thinking_budget: 1000
            }
          }
        end

        assert_equal 1000, Prompt.last.thinking_budget
        assert_redirected_to prompt_url(Prompt.last)
      end

      test "should create prompt with nested samples" do
        assert_difference("Prompt.count", 1) do
          assert_difference("Sample.count", 3) do
            post prompts_url, params: {
              prompt: {
                name: "Prompt with Multiple Samples",
                provider: "ollama",
                model: "gemma3",
                message: "Test",
                samples_attributes: [
                  { eval_type: "exact", expected_output: "output1", variables: {}.to_json },
                  { eval_type: "contains", expected_output: "output2", variables: {}.to_json },
                  { eval_type: "regex", expected_output: "(yes|no)", variables: {}.to_json }
                ]
              }
            }
          end
        end

        prompt = Prompt.last
        assert_equal 3, prompt.samples.count
        assert_redirected_to prompt_url(prompt)
      end

      test "should reject blank samples when creating prompt" do
        assert_difference("Prompt.count", 1) do
          assert_no_difference("Sample.count") do
            post prompts_url, params: {
              prompt: {
                name: "Prompt with Blank Sample",
                provider: "ollama",
                model: "gemma3",
                message: "Test",
                samples_attributes: [
                  { eval_type: "", expected_output: "", variables: "" }
                ]
              }
            }
          end
        end

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

      test "should update prompt and add new sample" do
        initial_sample_count = @prompt.samples.count

        assert_difference("Sample.count", 1) do
          patch prompt_url(@prompt), params: {
            prompt: {
              name: @prompt.name,
              provider: @prompt.provider,
              model: @prompt.model,
              message: @prompt.message,
              samples_attributes: [
                {
                  eval_type: "contains",
                  expected_output: "new test",
                  variables: {}.to_json
                }
              ]
            }
          }
        end

        @prompt.reload
        assert_equal initial_sample_count + 1, @prompt.samples.count
        assert_redirected_to prompt_url(@prompt)
      end

      test "should update prompt and remove sample via destroy" do
        sample = @prompt.samples.first

        assert_difference("Sample.count", -1) do
          patch prompt_url(@prompt), params: {
            prompt: {
              name: @prompt.name,
              provider: @prompt.provider,
              model: @prompt.model,
              message: @prompt.message,
              samples_attributes: [
                {
                  id: sample.id,
                  _destroy: "1"
                }
              ]
            }
          }
        end

        @prompt.reload
        assert_not @prompt.samples.exists?(sample.id)
        assert_redirected_to prompt_url(@prompt)
      end

      test "should update prompt and modify existing sample" do
        sample = @prompt.samples.first
        new_expected_output = "modified output"

        assert_no_difference("Sample.count") do
          patch prompt_url(@prompt), params: {
            prompt: {
              name: @prompt.name,
              provider: @prompt.provider,
              model: @prompt.model,
              message: @prompt.message,
              samples_attributes: [
                {
                  id: sample.id,
                  eval_type: sample.eval_type,
                  expected_output: new_expected_output,
                  variables: sample.variables.to_json
                }
              ]
            }
          }
        end

        sample.reload
        assert_equal new_expected_output, sample.expected_output
        assert_redirected_to prompt_url(@prompt)
      end

      test "should get compare" do
        get compare_prompt_url(@prompt)
        assert_response :success
      end
    end
  end
end
