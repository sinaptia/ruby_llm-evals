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
  end
end
