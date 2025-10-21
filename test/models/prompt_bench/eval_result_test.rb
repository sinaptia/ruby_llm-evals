require "test_helper"

module PromptBench
  class EvalResultTest < ActiveSupport::TestCase
    test "should be valid with all required attributes" do
      result = EvalResult.new(
        prompt: prompt_bench_prompts(:one),
        active_job_id: "test-job-id",
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test message"
      )
      assert result.valid?
    end

    test "should require active_job_id" do
      result = EvalResult.new(
        prompt: prompt_bench_prompts(:one),
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test message"
      )
      assert_not result.valid?
    end

    test "should require provider when manually set" do
      result = prompt_bench_eval_results(:one)
      result.provider = nil
      assert_not result.valid?
    end

    test "should require model when manually set" do
      result = prompt_bench_eval_results(:one)
      result.model = nil
      assert_not result.valid?
    end

    test "should require message when manually set" do
      result = prompt_bench_eval_results(:one)
      result.message = nil
      assert_not result.valid?
    end

    test "should copy prompt attributes on create" do
      prompt = prompt_bench_prompts(:one)
      result = EvalResult.create(
        prompt: prompt,
        active_job_id: "test-job-id-new"
      )

      assert_equal prompt.provider, result.provider
      assert_equal prompt.model, result.model
      assert_equal prompt.message, result.message
      assert_equal prompt.instructions, result.instructions
    end

    test "finished? should return true when ended_at is present" do
      result = prompt_bench_eval_results(:one)
      assert result.finished?
    end

    test "finished? should return false when ended_at is nil" do
      result = prompt_bench_eval_results(:two)
      assert_not result.finished?
    end

    test "accuracy should calculate percentage of passed executions" do
      result = prompt_bench_eval_results(:one)

      assert_equal 100.0, result.accuracy
    end

    test "accuracy should handle multiple executions" do
      result = prompt_bench_eval_results(:three)

      expected_accuracy = (1 * 100.0 / 2).round(2)
      assert_equal expected_accuracy, result.accuracy
    end

    test "cost should sum all execution costs" do
      result = prompt_bench_eval_results(:one)

      expected_cost = result.prompt_executions.sum(&:cost)
      assert_equal expected_cost, result.cost
    end

    test "cost should return 0.0 when no executions" do
      result = EvalResult.create(
        prompt: prompt_bench_prompts(:one),
        active_job_id: "test-no-executions"
      )

      assert_equal 0.0, result.cost
    end

    test "accuracy should return 0.0 when no executions" do
      result = EvalResult.create(
        prompt: prompt_bench_prompts(:one),
        active_job_id: "test-no-executions-accuracy"
      )

      assert_equal 0.0, result.accuracy
    end

    test "should copy temperature from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(temperature: 0.8)

      result = EvalResult.create(
        prompt: prompt,
        active_job_id: "test-temp-snapshot"
      )

      assert_equal 0.8, result.temperature
    end

    test "should copy params from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(params: { "max_tokens" => 500 })

      result = EvalResult.create(
        prompt: prompt,
        active_job_id: "test-params-snapshot"
      )

      assert_equal({ "max_tokens" => 500 }, result.params)
    end

    test "should copy tools from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(tools: [ "Weather", "Calculator" ])

      result = EvalResult.create(
        prompt: prompt,
        active_job_id: "test-tools-snapshot"
      )

      assert_equal [ "Weather", "Calculator" ], result.tools
    end

    test "should copy nil temperature from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(temperature: nil)

      result = EvalResult.create(
        prompt: prompt,
        active_job_id: "test-nil-temp-snapshot"
      )

      assert_nil result.temperature
    end

    test "should copy empty params from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(params: {})

      result = EvalResult.create(
        prompt: prompt,
        active_job_id: "test-empty-params-snapshot"
      )

      assert_equal({}, result.params)
    end

    test "should copy empty tools from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(tools: [])

      result = EvalResult.create(
        prompt: prompt,
        active_job_id: "test-empty-tools-snapshot"
      )

      assert_equal [], result.tools
    end

    test "should copy schema from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(schema: "WeatherSchema")

      result = EvalResult.create(
        prompt: prompt,
        active_job_id: "test-schema-snapshot"
      )

      assert_equal "WeatherSchema", result.schema
    end

    test "should copy schema_other from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(schema_other: { "type" => "object", "properties" => { "name" => { "type" => "string" } } })

      result = EvalResult.create(
        prompt: prompt,
        active_job_id: "test-schema-other-snapshot"
      )

      assert_equal({ "type" => "object", "properties" => { "name" => { "type" => "string" } } }, result.schema_other)
    end

    test "should copy nil schema from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(schema: nil)

      result = EvalResult.create(
        prompt: prompt,
        active_job_id: "test-nil-schema-snapshot"
      )

      assert_nil result.schema
    end

    test "should copy nil schema_other from prompt on create" do
      prompt = prompt_bench_prompts(:one)
      prompt.update(schema_other: nil)

      result = EvalResult.create(
        prompt: prompt,
        active_job_id: "test-nil-schema-other-snapshot"
      )

      assert_nil result.schema_other
    end
  end
end
