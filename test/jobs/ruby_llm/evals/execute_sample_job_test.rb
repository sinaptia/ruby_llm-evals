require "test_helper"

module RubyLLM
  module Evals
    class ExecuteSampleJobTest < ActiveJob::TestCase
      test "job creates prompt execution when executed" do
        VCR.use_cassette("execute_sample_job_creates_prompt_execution") do
          prompt = ruby_llm_evals_prompts(:one)
          run = Run.create!(prompt: prompt, active_job_id: "test-create", started_at: Time.current)
          sample = ruby_llm_evals_samples(:one)

          assert_difference "PromptExecution.count", 1 do
            ExecuteSampleJob.perform_now(run_id: run.id, sample_id: sample.id)
          end

          execution = PromptExecution.find_by!(run: run, sample: sample)
          assert_equal run, execution.run
          assert_equal sample, execution.sample
        end
      end

      test "job executes prompt and stores result" do
        VCR.use_cassette("execute_sample_job_executes_prompt") do
          prompt = ruby_llm_evals_prompts(:two)
          run = Run.create!(prompt: prompt, active_job_id: "test-execute", started_at: Time.current)
          sample = ruby_llm_evals_samples(:two)

          ExecuteSampleJob.perform_now(run_id: run.id, sample_id: sample.id)

          execution = PromptExecution.find_by!(run: run, sample: sample)
          assert_not_nil execution.message
          assert_not_nil execution.input
          assert_not_nil execution.output
          assert_not_nil execution.passed
        end
      end

      test "job copies sample configuration to prompt execution" do
        VCR.use_cassette("execute_sample_job_copies_sample_attributes") do
          prompt = ruby_llm_evals_prompts(:two)
          run = Run.create!(prompt: prompt, active_job_id: "test-copy", started_at: Time.current)
          sample = ruby_llm_evals_samples(:two)

          ExecuteSampleJob.perform_now(run_id: run.id, sample_id: sample.id)

          execution = PromptExecution.find_by!(run: run, sample: sample)
          assert_equal sample.eval_type, execution.eval_type
          assert_equal sample.expected_output, execution.expected_output
          assert_equal sample.variables, execution.variables
        end
      end

      test "job sets timestamps" do
        VCR.use_cassette("execute_sample_job_sets_timestamps") do
          prompt = ruby_llm_evals_prompts(:one)
          run = Run.create!(prompt: prompt, active_job_id: "test-timestamps", started_at: Time.current)
          sample = ruby_llm_evals_samples(:one)

          ExecuteSampleJob.perform_now(run_id: run.id, sample_id: sample.id)

          execution = PromptExecution.find_by!(run: run, sample: sample)
          assert_not_nil execution.started_at
          assert_not_nil execution.ended_at
          assert execution.ended_at >= execution.started_at
        end
      end

      test "job marks run as ended when all samples are executed" do
        VCR.use_cassette("execute_sample_job_marks_run_ended") do
          prompt = ruby_llm_evals_prompts(:one)
          sample = prompt.samples.first
          run = Run.create!(
            prompt: prompt,
            active_job_id: "test-job-complete",
            started_at: Time.current
          )

          assert_nil run.ended_at

          ExecuteSampleJob.perform_now(run_id: run.id, sample_id: sample.id)

          run.reload
          assert_not_nil run.ended_at
        end
      end

      test "job does not mark run as ended when not all samples are executed" do
        VCR.use_cassette("execute_sample_job_does_not_mark_run_ended_early") do
          prompt = ruby_llm_evals_prompts(:two)
          sample = ruby_llm_evals_samples(:two)

          run = Run.create!(
            prompt: prompt,
            active_job_id: "test-job-partial",
            started_at: Time.current
          )

          assert_nil run.ended_at

          ExecuteSampleJob.perform_now(run_id: run.id, sample_id: sample.id)

          run.reload
          assert_nil run.ended_at
        end
      end
    end
  end
end
