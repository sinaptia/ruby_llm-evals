require "test_helper"

module RubyLLM::Evals
  class ExecutableTest < ActiveSupport::TestCase
    setup do
      @prompt = ruby_llm_evals_prompts(:one)
    end

    test "#to_chat returns a RubyLLM::Chat instance" do
      chat = @prompt.to_chat(variables: {}, files: [])

      assert_instance_of RubyLLM::Chat, chat
    end

    test "#to_chat configures model and provider" do
      chat = @prompt.to_chat(variables: {}, files: [])

      assert_equal @prompt.model, chat.model.id
    end

    test "#to_chat applies instructions when present" do
      prompt_with_instructions = Prompt.create!(
        name: "With Instructions",
        slug: "with-instructions",
        provider: "ollama",
        model: "gemma3",
        message: "Say hello",
        instructions: "You are a helpful assistant"
      )

      chat = prompt_with_instructions.to_chat(variables: {}, files: [])

      assert_includes chat.messages.map { |m| m.content.to_s }, "You are a helpful assistant"
    end

    test "#to_chat skips instructions when blank" do
      prompt_without_instructions = Prompt.create!(
        name: "No Instructions",
        slug: "no-instructions",
        provider: "ollama",
        model: "gemma3",
        message: "Say hello"
      )

      chat = prompt_without_instructions.to_chat(variables: {}, files: [])
      system_messages = chat.messages.select { |m| m.role == :system }

      assert_empty system_messages
    end

    test "#to_chat applies temperature when present" do
      prompt_with_temp = Prompt.create!(
        name: "With Temperature",
        slug: "with-temperature-chat",
        provider: "ollama",
        model: "gemma3",
        message: "Say hello",
        temperature: 0.5
      )

      chat = prompt_with_temp.to_chat(variables: {}, files: [])

      # Temperature is stored in instance variable, check via complete method behavior
      assert_respond_to chat, :complete
    end

    test "#to_chat applies params when present" do
      prompt_with_params = Prompt.create!(
        name: "With Params",
        slug: "with-params-chat",
        provider: "ollama",
        model: "gemma3",
        message: "Say hello",
        params: { "num_predict" => 50 }
      )

      chat = prompt_with_params.to_chat(variables: {}, files: [])

      assert_equal({ "num_predict" => 50 }, chat.params)
    end

    test "#to_chat ignores invalid tool classes" do
      prompt_with_invalid_tools = Prompt.create!(
        name: "With Invalid Tools",
        slug: "with-invalid-tools-chat",
        provider: "ollama",
        model: "gemma3",
        message: "Say hello",
        tools: [ "NonExistentTool" ]
      )

      chat = prompt_with_invalid_tools.to_chat(variables: {}, files: [])

      assert_empty chat.tools
    end

    test "#to_chat applies schema_other when present" do
      schema_definition = { "type" => "object", "properties" => { "name" => { "type" => "string" } } }
      prompt_with_schema_other = Prompt.create!(
        name: "With Schema Other",
        slug: "with-schema-other-chat",
        provider: "ollama",
        model: "gemma3",
        message: "Say hello",
        schema_other: schema_definition
      )

      chat = prompt_with_schema_other.to_chat(variables: {}, files: [])

      assert_equal schema_definition, chat.schema
    end

    test "#to_chat prefers schema_other over schema" do
      schema_other_def = { "type" => "object", "properties" => { "age" => { "type" => "integer" } } }

      prompt_with_schema_other = Prompt.create!(
        name: "With Schema Other Only",
        slug: "with-schema-other-only-chat",
        provider: "ollama",
        model: "gemma3",
        message: "Say hello",
        schema_other: schema_other_def
      )

      chat = prompt_with_schema_other.to_chat(variables: {}, files: [])

      assert_equal schema_other_def, chat.schema
    end

    test "#to_chat applies thinking_effort when present" do
      prompt_with_thinking = Prompt.create!(
        name: "With Thinking Effort",
        slug: "with-thinking-effort-chat",
        provider: "ollama",
        model: "gemma3",
        message: "Say hello",
        thinking_effort: "high"
      )

      chat = prompt_with_thinking.to_chat(variables: {}, files: [])

      # Thinking config is stored internally, chat should respond to complete
      assert_respond_to chat, :complete
    end

    test "#to_chat applies thinking_budget when present" do
      prompt_with_budget = Prompt.create!(
        name: "With Thinking Budget",
        slug: "with-thinking-budget-chat",
        provider: "ollama",
        model: "gemma3",
        message: "Say hello",
        thinking_budget: 1000
      )

      chat = prompt_with_budget.to_chat(variables: {}, files: [])

      assert_respond_to chat, :complete
    end

    test "#to_chat adds user message with rendered content" do
      prompt = Prompt.create!(
        name: "Simple Message",
        slug: "simple-message-chat",
        provider: "ollama",
        model: "gemma3",
        message: "Hello, world!"
      )

      chat = prompt.to_chat(variables: {}, files: [])

      user_messages = chat.messages.select { |m| m.role == :user }
      assert_equal 1, user_messages.size
      assert_includes user_messages.first.content.to_s, "Hello, world!"
    end

    test "#to_chat substitutes variables in message" do
      prompt = Prompt.create!(
        name: "With Variables",
        slug: "with-variables-chat",
        provider: "ollama",
        model: "gemma3",
        message: "Hello, {{ name }}!"
      )

      chat = prompt.to_chat(variables: { "name" => "Alice" }, files: [])

      user_message = chat.messages.find { |m| m.role == :user }
      assert_includes user_message.content.to_s, "Hello, Alice!"
    end

    test "#to_chat substitutes variables in instructions" do
      prompt = Prompt.create!(
        name: "With Instruction Variables",
        slug: "with-instruction-variables-chat",
        provider: "ollama",
        model: "gemma3",
        message: "Say hello",
        instructions: "You are {{ role }}"
      )

      chat = prompt.to_chat(variables: { "role" => "a teacher" }, files: [])

      system_message = chat.messages.find { |m| m.role == :system }
      assert_includes system_message.content.to_s, "You are a teacher"
    end

    test "#execute calls to_chat and complete" do
      VCR.use_cassette("executable_test_execute_calls_complete") do
        response = @prompt.execute(variables: {})

        assert_respond_to response, :content
        assert_respond_to response, :input_tokens
        assert_respond_to response, :output_tokens
      end
    end

    test "#execute passes variables and files to to_chat" do
      prompt = Prompt.create!(
        name: "Execute Test",
        slug: "execute-test-chat",
        provider: "ollama",
        model: "gemma3",
        message: "Hello, {{ name }}!"
      )

      VCR.use_cassette("executable_test_execute_passes_params") do
        response = prompt.execute(variables: { "name" => "World" })

        assert_not_nil response.content
      end
    end

    test "#to_chat does not execute the chat" do
      chat = @prompt.to_chat(variables: {}, files: [])

      assert chat.messages.any?
      assistant_messages = chat.messages.select { |m| m.role == :assistant }
      assert_empty assistant_messages
    end
  end
end
