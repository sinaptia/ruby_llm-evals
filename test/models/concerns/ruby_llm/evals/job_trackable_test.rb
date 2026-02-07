require "test_helper"

module RubyLLM::Evals
  class JobTrackableTest < ActiveSupport::TestCase
    test "finished? returns true when ended_at is present" do
      run = ruby_llm_evals_runs(:one)
      assert run.finished?
    end

    test "finished? returns false when ended_at is nil" do
      run = ruby_llm_evals_runs(:two)
      assert_not run.finished?
    end

    test "validates presence of active_job_id" do
      run = Run.new(
        prompt: ruby_llm_evals_prompts(:one),
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        message: "Test message"
      )
      assert_not run.valid?
      assert_includes run.errors[:active_job_id], "can't be blank"
    end
  end
end
