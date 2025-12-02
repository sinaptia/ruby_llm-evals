require "test_helper"

module RubyLLM
  module Evals
    class PerformRunJobTest < ActiveJob::TestCase
      test "job creates run when executed" do
        VCR.use_cassette("perform_run_job_creates_result") do
          prompt = ruby_llm_evals_prompts(:one)
          assert_difference "Run.count", 1 do
            PerformRunJob.perform_now(prompt_id: prompt.id)
          end
        end
      end

      test "job executes all samples" do
        VCR.use_cassette("perform_run_job_test_executes_all_examples") do
          prompt = ruby_llm_evals_prompts(:two)
          perform_enqueued_jobs do
            PerformRunJob.perform_now(prompt_id: prompt.id)
          end

          run = Run.last
          assert_equal prompt.samples.count, run.prompt_executions.count
        end
      end

      test "job copies prompt configuration to run" do
        VCR.use_cassette("perform_run_job_test_copies_prompt_configuration") do
          prompt = ruby_llm_evals_prompts(:one)
          PerformRunJob.perform_now(prompt_id: prompt.id)

          run = Run.last
          assert_equal prompt.provider, run.provider
          assert_equal prompt.model, run.model
          assert_equal prompt.message, run.message
          assert_equal prompt.instructions, run.instructions
        end
      end

      test "job handles prompt with no examples" do
        VCR.use_cassette("perform_run_job_test_no_examples") do
          prompt = Prompt.create!(
            name: "No Examples Prompt",
            provider: "ollama",
            model: "gemma3",
            message: "Test message"
          )

          assert_difference "Run.count", 1 do
            PerformRunJob.perform_now(prompt_id: prompt.id)
          end

          run = Run.last
          assert_equal 0, run.prompt_executions.count
        end
      end

      test "job creates prompt_executions for all samples" do
        VCR.use_cassette("perform_run_job_test_creates_prompts_executions") do
          prompt = ruby_llm_evals_prompts(:two)
          perform_enqueued_jobs do
            PerformRunJob.perform_now(prompt_id: prompt.id)
          end

          run = Run.last
          assert_equal prompt.samples.count, run.prompt_executions.count

          prompt.samples.each do |sample|
            assert run.prompt_executions.exists?(sample: sample)
          end
        end
      end

      test "job sets ended_at timestamp" do
        VCR.use_cassette("perform_run_job_test_sets_timestamps") do
          prompt = ruby_llm_evals_prompts(:one)

          perform_enqueued_jobs do
            PerformRunJob.perform_now(prompt_id: prompt.id)
          end

          run = Run.last
          assert_not_nil run.started_at
          assert_not_nil run.ended_at
          assert run.ended_at >= run.started_at
        end
      end
    end
  end
end
