require "test_helper"

module PromptBench
  class PromptTest < ActiveSupport::TestCase
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
        name: prompt_bench_prompts(:one).name,
        provider: "openai",
        model: "gpt-4",
        message: "Different message"
      )
      assert_not prompt.valid?
    end

    test "should require unique slug" do
      prompt = Prompt.new(
        name: prompt_bench_prompts(:one).name, # Same name will generate same slug
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
  end
end
