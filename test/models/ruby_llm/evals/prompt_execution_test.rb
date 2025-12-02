require "test_helper"

module RubyLLM::Evals
  class PromptExecutionTest < ActiveSupport::TestCase
    test "should be valid with required attributes" do
      execution = PromptExecution.new(
        sample: ruby_llm_evals_samples(:one),
        run: ruby_llm_evals_runs(:one),
        eval_type: "exact",
        expected_output: "test",
        message: "test",
        active_job_id: "test-job-id"
      )
      assert execution.valid?
    end

    test "should require eval_type when manually set" do
      execution = ruby_llm_evals_prompt_executions(:one)
      execution.eval_type = nil
      assert_not execution.valid?
    end

    test "should copy sample attributes on create" do
      # Test via fixtures - the fixture should have copied attributes from sample
      execution = ruby_llm_evals_prompt_executions(:one)
      sample = execution.sample

      assert_equal sample.eval_type, execution.eval_type
      assert_equal sample.expected_output, execution.expected_output
      assert_equal sample.variables, execution.variables
    end

    test "cost should return 0.0 for local providers" do
      execution = ruby_llm_evals_prompt_executions(:two)

      assert_equal "ollama", execution.run.provider
      assert_equal 0.0, execution.cost
    end

    test "cost should calculate correctly for paid API providers" do
      execution = ruby_llm_evals_prompt_executions(:one)

      # Fixture has gemini provider with input: 1500, output: 20
      assert_equal "gemini", execution.run.provider
      assert_equal 1500, execution.input
      assert_equal 20, execution.output

      # Cost should be calculated based on gemini pricing
      assert execution.cost > 0.0
    end

    test "cost should return 0.0 when input and output are nil" do
      execution = PromptExecution.new(
        sample: ruby_llm_evals_samples(:one),
        run: ruby_llm_evals_runs(:one),
        eval_type: "exact",
        expected_output: "test",
        message: "test",
        input: nil,
        output: nil
      )

      assert_equal 0.0, execution.cost
    end

    test "should track input tokens" do
      execution = ruby_llm_evals_prompt_executions(:one)

      assert_not_nil execution.input
      assert execution.input > 0
    end

    test "should track output tokens" do
      execution = ruby_llm_evals_prompt_executions(:one)

      assert_not_nil execution.output
      assert execution.output > 0
    end

    test "should copy file attachments from sample on create" do
      sample = ruby_llm_evals_samples(:one)
      run = ruby_llm_evals_runs(:one)

      # Attach a file to sample
      sample.files.attach(
        io: StringIO.new("test file content"),
        filename: "test.txt",
        content_type: "text/plain"
      )

      execution = PromptExecution.create(sample:, run:, active_job_id: "test-job-id")

      assert_equal sample.files.count, execution.files.count
      assert_equal "test.txt", execution.files.first.filename.to_s
    end

    test "should normalize empty hash variables to nil" do
      execution = PromptExecution.create!(
        sample: ruby_llm_evals_samples(:one),
        run: ruby_llm_evals_runs(:one),
        active_job_id: "test-job-id"
      )
      execution.update_column(:variables, "{}")
      execution.reload
      execution.update(variables: {})

      assert_nil execution.variables
      assert_nil execution.reload.variables
    end

    test "should normalize empty array variables to nil" do
      execution = PromptExecution.create!(
        sample: ruby_llm_evals_samples(:one),
        run: ruby_llm_evals_runs(:one),
        active_job_id: "test-job-id"
      )
      execution.update_column(:variables, "[]")
      execution.reload
      execution.update(variables: [])

      assert_nil execution.variables
      assert_nil execution.reload.variables
    end

    test "should normalize empty string variables to nil" do
      execution = PromptExecution.create!(
        sample: ruby_llm_evals_samples(:one),
        run: ruby_llm_evals_runs(:one),
        active_job_id: "test-job-id"
      )
      execution.update_column(:variables, '""')
      execution.reload
      execution.update(variables: "")

      assert_nil execution.variables
      assert_nil execution.reload.variables
    end

    test "should not normalize variables with data" do
      execution = PromptExecution.create!(
        sample: ruby_llm_evals_samples(:one),
        run: ruby_llm_evals_runs(:one),
        active_job_id: "test-job-id"
      )
      execution.update(variables: { "key" => "value" })

      assert_equal({ "key" => "value" }, execution.variables)
      assert_equal({ "key" => "value" }, execution.reload.variables)
    end
  end
end
