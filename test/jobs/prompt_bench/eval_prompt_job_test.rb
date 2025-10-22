require "test_helper"

module PromptBench
  class EvalPromptJobTest < ActiveJob::TestCase
    test "job creates eval_result when executed" do
      VCR.use_cassette("eval_prompt_job_creates_result") do
        prompt = prompt_bench_prompts(:one)
        assert_difference "EvalResult.count", 1 do
          EvalPromptJob.perform_now(prompt_id: prompt.id)
        end
      end
    end

    test "job executes all samples" do
      VCR.use_cassette("eval_prompt_job_test_executes_all_examples") do
        prompt = prompt_bench_prompts(:two)
        EvalPromptJob.perform_now(prompt_id: prompt.id)

        eval_result = EvalResult.last
        assert_equal prompt.samples.count, eval_result.prompt_executions.count
      end
    end

    test "job copies prompt configuration to eval_result" do
      VCR.use_cassette("eval_prompt_job_test_copies_prompt_configuration") do
        prompt = prompt_bench_prompts(:one)
        EvalPromptJob.perform_now(prompt_id: prompt.id)

        eval_result = EvalResult.last
        assert_equal prompt.provider, eval_result.provider
        assert_equal prompt.model, eval_result.model
        assert_equal prompt.message, eval_result.message
        assert_equal prompt.instructions, eval_result.instructions
      end
    end

    test "job handles prompt with no examples" do
      VCR.use_cassette("eval_prompt_job_test_no_examples") do
        prompt = Prompt.create!(
          name: "No Examples Prompt",
          provider: "ollama",
          model: "gemma3",
          message: "Test message"
        )

        assert_difference "EvalResult.count", 1 do
          EvalPromptJob.perform_now(prompt_id: prompt.id)
        end

        eval_result = EvalResult.last
        assert_equal 0, eval_result.prompt_executions.count
      end
    end

    test "job creates prompt_executions for all samples" do
      VCR.use_cassette("eval_prompt_job_test_creates_prompts_executions") do
        prompt = prompt_bench_prompts(:two)
        EvalPromptJob.perform_now(prompt_id: prompt.id)

        eval_result = EvalResult.last
        assert_equal prompt.samples.count, eval_result.prompt_executions.count

        prompt.samples.each do |sample|
          assert eval_result.prompt_executions.exists?(sample: sample)
        end
      end
    end

    test "job sets ended_at timestamp" do
      VCR.use_cassette("eval_prompt_job_test_sets_timestamps") do
        prompt = prompt_bench_prompts(:one)

        EvalPromptJob.perform_now(prompt_id: prompt.id)

        eval_result = EvalResult.last
        assert_not_nil eval_result.started_at
        assert_not_nil eval_result.ended_at
        assert eval_result.ended_at >= eval_result.started_at
      end
    end
  end
end
