require "test_helper"

module PromptBench
  class PromptExecutorTest < ActiveSupport::TestCase
    setup do
      @prompt = prompt_bench_prompts(:one)
    end

    test ".execute finds prompt by slug and returns response object" do
      variables = { "text" => "This is a long text that needs to be summarized." }

      VCR.use_cassette("prompt_executor_test_call_by_slug") do
        response = PromptExecutor.execute("text-summarization", variables: variables)

        assert_respond_to response, :content
        assert_not_empty response.content
      end
    end

    test ".execute raises error when prompt not found" do
      assert_raises ActiveRecord::RecordNotFound do
        PromptExecutor.execute("nonexistent-slug", variables: {})
      end
    end

    test ".execute accepts slug and returns RubyLLM response object" do
      VCR.use_cassette("prompt_executor_test_execute_with_slug") do
        response = PromptExecutor.execute("image-categorization", variables: {})

        assert_respond_to response, :content
        assert_respond_to response, :input_tokens
        assert_respond_to response, :output_tokens
      end
    end

    test ".execute returns RubyLLM response object" do
      VCR.use_cassette("prompt_executor_test_execute_returns_response") do
        response = PromptExecutor.execute(@prompt.slug, variables: {})

        assert_respond_to response, :content
        assert_respond_to response, :input_tokens
        assert_respond_to response, :output_tokens
      end
    end

    test ".execute substitutes variables in message" do
      VCR.use_cassette("prompt_executor_test_substitutes_in_message") do
        response = PromptExecutor.execute(@prompt.slug, variables: {})

        assert_not_nil response
        assert_not_nil response.content
      end
    end

    test ".execute substitutes variables in instructions" do
      VCR.use_cassette("prompt_executor_test_substitutes_in_instructions") do
        response = PromptExecutor.execute(@prompt.slug, variables: {})

        assert_not_nil response
        assert_not_nil response.content
      end
    end

    test ".execute works without instructions" do
      # Use sentiment-analysis fixture which has no instructions
      VCR.use_cassette("prompt_executor_test_no_instructions") do
        response = PromptExecutor.execute("sentiment-analysis", variables: { "text" => "This is great!" })

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

      VCR.use_cassette("prompt_executor_test_no_variables") do
        response = PromptExecutor.execute("no-variables", variables: {})

        assert_not_nil response
        assert_not_nil response.content
      end
    end

    test ".execute handles files parameter" do
      VCR.use_cassette("prompt_executor_test_handles_files") do
        response = PromptExecutor.execute(@prompt.slug, variables: {}, files: [])

        assert_not_nil response
        assert_not_nil response.content
      end
    end
  end
end
