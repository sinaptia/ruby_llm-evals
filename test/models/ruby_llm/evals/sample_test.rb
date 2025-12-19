require "test_helper"

module RubyLLM::Evals
  class SampleTest < ActiveSupport::TestCase
    test "should be valid with required attributes" do
      sample = Sample.new(
        prompt: ruby_llm_evals_prompts(:one),
        eval_type: "exact",
        expected_output: "test"
      )
      assert sample.valid?
    end

    test "should require eval_type" do
      sample = Sample.new(
        prompt: ruby_llm_evals_prompts(:one),
        expected_output: "test"
      )
      assert_not sample.valid?
    end

    test "should require expected_output for exact eval_type" do
      sample = Sample.new(
        prompt: ruby_llm_evals_prompts(:one),
        eval_type: "exact"
      )
      assert_not sample.valid?
    end

    test "should require expected_output for contains eval_type" do
      sample = Sample.new(
        prompt: ruby_llm_evals_prompts(:one),
        eval_type: "contains"
      )
      assert_not sample.valid?
    end

    test "should require expected_output for regex eval_type" do
      sample = Sample.new(
        prompt: ruby_llm_evals_prompts(:one),
        eval_type: "regex"
      )
      assert_not sample.valid?
    end

    test "should not require expected_output for human eval_type" do
      sample = Sample.new(
        prompt: ruby_llm_evals_prompts(:one),
        eval_type: "human"
      )
      assert sample.valid?
    end

    test "should require judge_model for llm_judge eval_type" do
      sample = ruby_llm_evals_samples(:five)
      sample.judge_model = nil

      assert_not sample.valid?
      assert_includes sample.errors[:judge_model], "can't be blank"
    end

    test "should require judge_provider for llm_judge eval_type" do
      sample = ruby_llm_evals_samples(:five)
      sample.judge_provider = nil

      assert_not sample.valid?
      assert_includes sample.errors[:judge_provider], "can't be blank"
    end

    test "should be valid with all required attributes for llm_judge eval_type" do
      sample = ruby_llm_evals_samples(:five)

      assert sample.valid?
      assert_equal "llm_judge", sample.eval_type
      assert_equal "gemini-2.0-flash-001", sample.judge_model
      assert_equal "gemini", sample.judge_provider
    end

    test "should not require judge_model for non-llm_judge eval_types" do
      sample = ruby_llm_evals_samples(:one)

      assert sample.valid?
      assert_equal "exact", sample.eval_type
      assert_nil sample.judge_model
      assert_nil sample.judge_provider
    end

    test "should normalize empty hash variables to nil" do
      sample = Sample.create!(
        prompt: ruby_llm_evals_prompts(:one),
        eval_type: "exact",
        expected_output: "test",
        variables: {}
      )
      assert_nil sample.variables
      assert_nil sample.reload.variables
    end

    test "should normalize empty array variables to nil" do
      sample = Sample.create!(
        prompt: ruby_llm_evals_prompts(:one),
        eval_type: "exact",
        expected_output: "test",
        variables: []
      )
      assert_nil sample.variables
      assert_nil sample.reload.variables
    end

    test "should normalize empty string variables to nil" do
      sample = Sample.create!(
        prompt: ruby_llm_evals_prompts(:one),
        eval_type: "exact",
        expected_output: "test",
        variables: ""
      )
      assert_nil sample.variables
      assert_nil sample.reload.variables
    end

    test "should not normalize variables with data" do
      sample = Sample.create!(
        prompt: ruby_llm_evals_prompts(:one),
        eval_type: "exact",
        expected_output: "test",
        variables: { "key" => "value" }
      )
      assert_equal({ "key" => "value" }, sample.variables)
      assert_equal({ "key" => "value" }, sample.reload.variables)
    end
  end
end
