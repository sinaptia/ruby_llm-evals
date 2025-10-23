require "test_helper"

module RubyLLM::Evals
  class PromptTest < ActiveSupport::TestCase
    setup do
      @prompt = ruby_llm_evals_prompts(:one)
    end

    test "should be valid with all required attributes" do
      prompt = Prompt.new(
        name: "Test Prompt",
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test message"
      )
      assert prompt.valid?
    end

    test "should require name" do
      prompt = Prompt.new(
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test message"
      )
      assert_not prompt.valid?
    end

    test "should require provider" do
      prompt = Prompt.new(
        name: "Test Prompt",
        model: "claude-3-5-sonnet-20241022",
        message: "Test message"
      )
      assert_not prompt.valid?
    end

    test "should require model" do
      prompt = Prompt.new(
        name: "Test Prompt",
        provider: "anthropic",
        message: "Test message"
      )
      assert_not prompt.valid?
    end

    test "should require message" do
      prompt = Prompt.new(
        name: "Test Prompt",
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022"
      )
      assert_not prompt.valid?
    end

    test "should require unique name" do
      prompt = Prompt.new(
        name: ruby_llm_evals_prompts(:one).name,
        provider: "openai",
        model: "gpt-4",
        message: "Different message"
      )
      assert_not prompt.valid?
    end

    test "should require unique slug" do
      prompt = Prompt.new(
        name: ruby_llm_evals_prompts(:one).name, # Same name will generate same slug
        provider: "openai",
        model: "gpt-4",
        message: "Different message"
      )
      assert_not prompt.valid?
    end

    test "should auto-generate slug from name" do
      prompt = Prompt.new(
        name: "My Test Prompt",
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test message"
      )
      prompt.valid?
      assert_equal "my-test-prompt", prompt.slug
    end

    test "should parameterize slug from name with special characters" do
      prompt = Prompt.new(
        name: "Test Prompt: With Special! Characters?",
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test message"
      )
      prompt.valid?
      assert_equal "test-prompt-with-special-characters", prompt.slug
    end

    test ".execute finds prompt by slug and returns response object" do
      variables = { "text" => "This is a long text that needs to be summarized." }

      VCR.use_cassette("prompt_test_call_by_slug") do
        response = Prompt.execute("text-summarization", variables: variables)

        assert_respond_to response, :content
        assert_not_empty response.content
      end
    end

    test ".execute raises error when prompt not found" do
      assert_raises ActiveRecord::RecordNotFound do
        Prompt.execute("nonexistent-slug", variables: {})
      end
    end

    test ".execute accepts slug and returns RubyLLM response object" do
      VCR.use_cassette("prompt_test_execute_with_slug") do
        response = Prompt.execute("image-categorization", variables: {})

        assert_respond_to response, :content
        assert_respond_to response, :input_tokens
        assert_respond_to response, :output_tokens
      end
    end

    test ".execute returns RubyLLM response object" do
      VCR.use_cassette("prompt_test_execute_returns_response") do
        response = Prompt.execute(@prompt.slug, variables: {})

        assert_respond_to response, :content
        assert_respond_to response, :input_tokens
        assert_respond_to response, :output_tokens
      end
    end

    test ".execute substitutes variables in message" do
      VCR.use_cassette("prompt_test_substitutes_in_message") do
        response = Prompt.execute(@prompt.slug, variables: {})

        assert_not_nil response
        assert_not_nil response.content
      end
    end

    test ".execute substitutes variables in instructions" do
      VCR.use_cassette("prompt_test_substitutes_in_instructions") do
        response = Prompt.execute(@prompt.slug, variables: {})

        assert_not_nil response
        assert_not_nil response.content
      end
    end

    test ".execute works without instructions" do
      # Use sentiment-analysis fixture which has no instructions
      VCR.use_cassette("prompt_test_no_instructions") do
        response = Prompt.execute("sentiment-analysis", variables: { "text" => "This is great!" })

        assert_not_nil response
        assert_not_nil response.content
      end
    end

    test ".execute works with empty variables" do
      # Create a prompt without any variable placeholders
      Prompt.create!(
        name: "No Variables",
        slug: "no-variables",
        message: "No substitution needed",
        model: "gemma3",
        provider: "ollama"
      )

      VCR.use_cassette("prompt_test_no_variables") do
        response = Prompt.execute("no-variables", variables: {})

        assert_not_nil response
        assert_not_nil response.content
      end
    end

    test ".execute handles files parameter" do
      VCR.use_cassette("prompt_test_handles_files") do
        response = Prompt.execute(@prompt.slug, variables: {}, files: [])

        assert_not_nil response
        assert_not_nil response.content
      end
    end

    test "#execute instance method returns RubyLLM response object" do
      VCR.use_cassette("prompt_test_execute_returns_response") do
        response = @prompt.execute(variables: {})

        assert_respond_to response, :content
        assert_respond_to response, :input_tokens
        assert_respond_to response, :output_tokens
      end
    end

    test "should accept temperature as float" do
      prompt = Prompt.new(
        name: "Temperature Test",
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test",
        temperature: 0.7
      )
      assert_equal 0.7, prompt.temperature
    end

    test "should accept temperature as integer" do
      prompt = Prompt.new(
        name: "Temperature Test Int",
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test",
        temperature: 1
      )
      assert_equal 1.0, prompt.temperature
    end

    test ".execute should work with temperature" do
      prompt = Prompt.create!(
        name: "With Temperature",
        slug: "with-temperature",
        provider: "ollama",
        model: "gemma3",
        message: "Say hello",
        temperature: 0.5
      )

      VCR.use_cassette("prompt_test_with_temperature") do
        response = prompt.execute(variables: {})
        assert_not_nil response
        assert_not_nil response.content
      end
    end

    test ".execute should work with params" do
      prompt = Prompt.create!(
        name: "With Params",
        slug: "with-params",
        provider: "ollama",
        model: "gemma3",
        message: "Say hello",
        params: { "num_predict" => 50 }
      )

      VCR.use_cassette("prompt_test_with_params") do
        response = prompt.execute(variables: {})
        assert_not_nil response
        assert_not_nil response.content
      end
    end

    test "should accept schema as string" do
      prompt = Prompt.new(
        name: "With Schema",
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test",
        schema: "WeatherSchema"
      )
      assert_equal "WeatherSchema", prompt.schema
    end

    test "should accept schema_other as json" do
      prompt = Prompt.new(
        name: "With Schema Other",
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test",
        schema_other: { "type" => "object", "properties" => { "name" => { "type" => "string" } } }
      )
      assert_equal({ "type" => "object", "properties" => { "name" => { "type" => "string" } } }, prompt.schema_other)
    end

    test "should validate schema_other is valid json" do
      prompt = Prompt.new(
        name: "Invalid Schema Other",
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test"
      )
      prompt.schema_other = "invalid json"
      assert_not prompt.valid?
      assert prompt.errors[:schema_other].present?
    end

    test "should normalize empty hash params to nil" do
      prompt = Prompt.create!(
        name: "Empty Params Test",
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test",
        params: {}
      )
      assert_nil prompt.params
      assert_nil prompt.reload.params
    end

    test "should normalize empty array tools to nil" do
      prompt = Prompt.create!(
        name: "Empty Tools Test",
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test",
        tools: []
      )
      assert_nil prompt.tools
      assert_nil prompt.reload.tools
    end

    test "should normalize empty string schema_other to nil" do
      prompt = Prompt.create!(
        name: "Empty Schema Other Test",
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test",
        schema_other: ""
      )
      assert_nil prompt.schema_other
      assert_nil prompt.reload.schema_other
    end

    test "should not normalize params with data" do
      prompt = Prompt.create!(
        name: "Params With Data Test",
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test",
        params: { "key" => "value" }
      )
      assert_equal({ "key" => "value" }, prompt.params)
      assert_equal({ "key" => "value" }, prompt.reload.params)
    end

    test "should not normalize tools with data" do
      prompt = Prompt.create!(
        name: "Tools With Data Test",
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test",
        tools: [ "Calculator" ]
      )
      assert_equal([ "Calculator" ], prompt.tools)
      assert_equal([ "Calculator" ], prompt.reload.tools)
    end

    test "should not normalize schema_other with data" do
      prompt = Prompt.create!(
        name: "Schema Other With Data Test",
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test",
        schema_other: { "type" => "object" }
      )
      assert_equal({ "type" => "object" }, prompt.schema_other)
      assert_equal({ "type" => "object" }, prompt.reload.schema_other)
    end
  end
end
