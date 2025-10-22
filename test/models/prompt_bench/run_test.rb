require "test_helper"

module PromptBench
  class RunTest < ActiveSupport::TestCase
    test "should be valid with all required attributes" do
      result = Run.new(
        prompt: prompt_bench_prompts(:one),
        active_job_id: "test-job-id",
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test message"
      )
      assert result.valid?
    end

    test "should require active_job_id" do
      result = Run.new(
        prompt: prompt_bench_prompts(:one),
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test message"
      )
      assert_not result.valid?
    end

    test "should require provider when manually set" do
      result = prompt_bench_runs(:one)
      result.provider = nil
      assert_not result.valid?
    end

    test "should require model when manually set" do
      result = prompt_bench_runs(:one)
      result.model = nil
      assert_not result.valid?
    end

    test "should require message when manually set" do
      result = prompt_bench_runs(:one)
      result.message = nil
      assert_not result.valid?
    end

    test "should copy prompt attributes on create" do
      prompt = prompt_bench_prompts(:one)
      result = Run.create(
        prompt: prompt,
        active_job_id: "test-job-id-new"
      )

      assert_equal prompt.provider, result.provider
      assert_equal prompt.model, result.model
      assert_equal prompt.message, result.message
      assert_equal prompt.instructions, result.instructions
    end

    test "finished? should return true when ended_at is present" do
      result = prompt_bench_runs(:one)
      assert result.finished?
    end

    test "finished? should return false when ended_at is nil" do
      result = prompt_bench_runs(:two)
      assert_not result.finished?
    end

    test "accuracy should calculate percentage of passed executions" do
      result = prompt_bench_runs(:one)

      assert_equal 100.0, result.accuracy
    end

    test "accuracy should handle multiple executions" do
      result = prompt_bench_runs(:three)

      expected_accuracy = (1 * 100.0 / 2).round(2)
      assert_equal expected_accuracy, result.accuracy
    end

    test "cost should sum all execution costs" do
      result = prompt_bench_runs(:one)

      expected_cost = result.prompt_executions.sum(&:cost)
      assert_equal expected_cost, result.cost
    end

    test "cost should return 0.0 when no executions" do
      result = Run.create(
        prompt: prompt_bench_prompts(:one),
        active_job_id: "test-no-executions"
      )

      assert_equal 0.0, result.cost
    end

    test "accuracy should return 0.0 when no executions" do
      result = Run.create(
        prompt: prompt_bench_prompts(:one),
        active_job_id: "test-no-executions-accuracy"
      )

      assert_equal 0.0, result.accuracy
    end

    test "should copy temperature from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(temperature: 0.8)

      result = Run.create(
        prompt: prompt,
        active_job_id: "test-temp-snapshot"
      )

      assert_equal 0.8, result.temperature
    end

    test "should copy params from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(params: { "max_tokens" => 500 })

      result = Run.create(
        prompt: prompt,
        active_job_id: "test-params-snapshot"
      )

      assert_equal({ "max_tokens" => 500 }, result.params)
    end

    test "should copy tools from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(tools: [ "Weather", "Calculator" ])

      result = Run.create(
        prompt: prompt,
        active_job_id: "test-tools-snapshot"
      )

      assert_equal [ "Weather", "Calculator" ], result.tools
    end

    test "should copy nil temperature from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(temperature: nil)

      result = Run.create(
        prompt: prompt,
        active_job_id: "test-nil-temp-snapshot"
      )

      assert_nil result.temperature
    end

    test "should copy normalized params from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(params: {})

      result = Run.create(
        prompt: prompt,
        active_job_id: "test-empty-params-snapshot"
      )

      # Empty hash should be normalized to nil on the prompt
      assert_nil prompt.params
      assert_nil result.params
    end

    test "should copy normalized tools from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(tools: [])

      result = Run.create(
        prompt: prompt,
        active_job_id: "test-empty-tools-snapshot"
      )

      # Empty array should be normalized to nil on the prompt
      assert_nil prompt.tools
      assert_nil result.tools
    end

    test "should copy schema from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(schema: "WeatherSchema")

      result = Run.create(
        prompt: prompt,
        active_job_id: "test-schema-snapshot"
      )

      assert_equal "WeatherSchema", result.schema
    end

    test "should copy schema_other from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(schema_other: { "type" => "object", "properties" => { "name" => { "type" => "string" } } })

      result = Run.create(
        prompt: prompt,
        active_job_id: "test-schema-other-snapshot"
      )

      assert_equal({ "type" => "object", "properties" => { "name" => { "type" => "string" } } }, result.schema_other)
    end

    test "should copy nil schema from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(schema: nil)

      result = Run.create(
        prompt: prompt,
        active_job_id: "test-nil-schema-snapshot"
      )

      assert_nil result.schema
    end

    test "should copy nil schema_other from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(schema_other: nil)

      result = Run.create(
        prompt: prompt,
        active_job_id: "test-nil-schema-other-snapshot"
      )

      assert_nil result.schema_other
    end

    test "should normalize empty hash params to nil" do
      result = Run.create!(
        prompt: prompt_bench_prompts(:one),
        active_job_id: "normalize-params-test"
      )
      result.update(params: {})

      assert_nil result.params
      assert_nil result.reload.params
    end

    test "should normalize empty array tools to nil" do
      result = Run.create!(
        prompt: prompt_bench_prompts(:one),
        active_job_id: "normalize-tools-test"
      )
      result.update(tools: [])

      assert_nil result.tools
      assert_nil result.reload.tools
    end

    test "should normalize empty string schema_other to nil" do
      result = Run.create!(
        prompt: prompt_bench_prompts(:one),
        active_job_id: "normalize-schema-other-test"
      )
      result.update(schema_other: "")

      assert_nil result.schema_other
      assert_nil result.reload.schema_other
    end

    test "should not normalize params with data" do
      result = Run.create!(
        prompt: prompt_bench_prompts(:one),
        active_job_id: "params-with-data-test"
      )
      result.update(params: { "key" => "value" })

      assert_equal({ "key" => "value" }, result.params)
      assert_equal({ "key" => "value" }, result.reload.params)
    end
  end
end
