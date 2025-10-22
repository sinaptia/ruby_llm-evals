require "test_helper"

module PromptBench
  class SampleTest < ActiveSupport::TestCase
    test "should be valid with required attributes" do
      sample = Sample.new(
        prompt: prompt_bench_prompts(:one),
        eval_type: "exact",
        expected_output: "test"
      )
      assert sample.valid?
    end

    test "should require eval_type" do
      sample = Sample.new(
        prompt: prompt_bench_prompts(:one),
        expected_output: "test"
      )
      assert_not sample.valid?
    end

    test "should require expected_output for exact eval_type" do
      sample = Sample.new(
        prompt: prompt_bench_prompts(:one),
        eval_type: "exact"
      )
      assert_not sample.valid?
    end

    test "should require expected_output for contains eval_type" do
      sample = Sample.new(
        prompt: prompt_bench_prompts(:one),
        eval_type: "contains"
      )
      assert_not sample.valid?
    end

    test "should require expected_output for regex eval_type" do
      sample = Sample.new(
        prompt: prompt_bench_prompts(:one),
        eval_type: "regex"
      )
      assert_not sample.valid?
    end

    test "should not require expected_output for human eval_type" do
      sample = Sample.new(
        prompt: prompt_bench_prompts(:one),
        eval_type: "human"
      )
      assert sample.valid?
    end

    test "should normalize empty hash variables to nil" do
      sample = Sample.create!(
        prompt: prompt_bench_prompts(:one),
        eval_type: "exact",
        expected_output: "test",
        variables: {}
      )
      assert_nil sample.variables
      assert_nil sample.reload.variables
    end

    test "should normalize empty array variables to nil" do
      sample = Sample.create!(
        prompt: prompt_bench_prompts(:one),
        eval_type: "exact",
        expected_output: "test",
        variables: []
      )
      assert_nil sample.variables
      assert_nil sample.reload.variables
    end

    test "should normalize empty string variables to nil" do
      sample = Sample.create!(
        prompt: prompt_bench_prompts(:one),
        eval_type: "exact",
        expected_output: "test",
        variables: ""
      )
      assert_nil sample.variables
      assert_nil sample.reload.variables
    end

    test "should not normalize variables with data" do
      sample = Sample.create!(
        prompt: prompt_bench_prompts(:one),
        eval_type: "exact",
        expected_output: "test",
        variables: { "key" => "value" }
      )
      assert_equal({ "key" => "value" }, sample.variables)
      assert_equal({ "key" => "value" }, sample.reload.variables)
    end
  end
end
