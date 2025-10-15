require "test_helper"

module PromptBench
  class EvalExampleTest < ActiveSupport::TestCase
    test "should be valid with required attributes" do
      example = EvalExample.new(
        prompt: prompt_bench_prompts(:one),
        eval_type: "exact",
        expected_output: "test"
      )
      assert example.valid?
    end

    test "should require eval_type" do
      example = EvalExample.new(
        prompt: prompt_bench_prompts(:one),
        expected_output: "test"
      )
      assert_not example.valid?
    end

    test "should require expected_output for exact eval_type" do
      example = EvalExample.new(
        prompt: prompt_bench_prompts(:one),
        eval_type: "exact"
      )
      assert_not example.valid?
    end

    test "should require expected_output for contains eval_type" do
      example = EvalExample.new(
        prompt: prompt_bench_prompts(:one),
        eval_type: "contains"
      )
      assert_not example.valid?
    end

    test "should require expected_output for regex eval_type" do
      example = EvalExample.new(
        prompt: prompt_bench_prompts(:one),
        eval_type: "regex"
      )
      assert_not example.valid?
    end

    test "should not require expected_output for human eval_type" do
      example = EvalExample.new(
        prompt: prompt_bench_prompts(:one),
        eval_type: "human"
      )
      assert example.valid?
    end

    test "variables setter should parse JSON string" do
      example = EvalExample.new(
        prompt: prompt_bench_prompts(:one),
        eval_type: "exact",
        expected_output: "test"
      )
      example.variables = '{"name": "John", "age": 30}'

      assert_equal({ "name" => "John", "age" => 30 }, example.variables)
    end

    test "variables setter should handle hash directly" do
      example = EvalExample.new(
        prompt: prompt_bench_prompts(:one),
        eval_type: "exact",
        expected_output: "test"
      )
      example.variables = { "name" => "John", "age" => 30 }

      assert_equal({ "name" => "John", "age" => 30 }, example.variables)
    end

    test "variables setter should handle empty string" do
      example = EvalExample.new(
        prompt: prompt_bench_prompts(:one),
        eval_type: "exact",
        expected_output: "test"
      )
      example.variables = ""

      assert_equal "", example.variables
    end

    test "variables setter should handle nil" do
      example = EvalExample.new(
        prompt: prompt_bench_prompts(:one),
        eval_type: "exact",
        expected_output: "test"
      )
      example.variables = nil

      assert_nil example.variables
    end

    test "variables setter should handle invalid JSON gracefully" do
      example = EvalExample.new(
        prompt: prompt_bench_prompts(:one),
        eval_type: "exact",
        expected_output: "test"
      )
      example.variables = "{invalid json}"

      assert_equal "{invalid json}", example.variables
    end
  end
end
