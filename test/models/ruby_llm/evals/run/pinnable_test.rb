require "test_helper"

module RubyLLM::Evals
  class Run::PinnableTest < ActiveSupport::TestCase
    setup do
      @prompt = ruby_llm_evals_prompts(:one)
      @run = ruby_llm_evals_runs(:one)
    end

    test "pinned? returns false when pinned_at is nil" do
      @run.update!(pinned_at: nil)
      assert_not @run.pinned?
    end

    test "pinned? returns true when pinned_at is present" do
      @run.update!(pinned_at: Time.current)
      assert @run.pinned?
    end

    test "pin! sets pinned_at to current time" do
      freeze_time do
        @run.update!(pinned_at: nil)
        @run.pin!
        assert_equal Time.current, @run.pinned_at
      end
    end

    test "pin! removes pin from other runs of same prompt" do
      other_run = Run.create!(
        prompt: @prompt,
        active_job_id: "other-pin-test",
        provider: "openai",
        model: "gpt-4",
        message: "Other run message",
        pinned_at: Time.current
      )

      @run.pin!

      assert @run.pinned?
      assert_not other_run.reload.pinned?
    end

    test "pin! allows multiple prompts to have pinned runs" do
      other_prompt = ruby_llm_evals_prompts(:two)
      other_run = ruby_llm_evals_runs(:three)
      other_run.update!(prompt: other_prompt, pinned_at: Time.current)

      @run.pin!

      assert @run.pinned?
      assert other_run.reload.pinned?
    end

    test "unpin! sets pinned_at to nil" do
      @run.update!(pinned_at: Time.current)
      @run.unpin!
      assert_nil @run.pinned_at
    end

    test "pinned scope returns only pinned runs" do
      @run.update!(pinned_at: Time.current)
      ruby_llm_evals_runs(:two).update!(pinned_at: nil)

      pinned = Run.pinned

      assert_includes pinned, @run
      assert_not_includes pinned, ruby_llm_evals_runs(:two)
    end
  end
end
