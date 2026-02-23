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

    test "should copy judge fields from sample on create" do
      sample = ruby_llm_evals_samples(:five)
      run = ruby_llm_evals_runs(:one)

      execution = PromptExecution.create!(
        sample: sample,
        run: run,
        active_job_id: "test-job-id"
      )

      assert_equal sample.judge_model, execution.judge_model
      assert_equal sample.judge_provider, execution.judge_provider
    end

    test "should handle nil judge fields from sample on create" do
      sample = ruby_llm_evals_samples(:one)
      run = ruby_llm_evals_runs(:one)

      execution = PromptExecution.create!(
        sample: sample,
        run: run,
        active_job_id: "test-job-id"
      )

      assert_nil execution.judge_model
      assert_nil execution.judge_provider
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

    test "should normalize empty hash judge_message to nil" do
      execution = ruby_llm_evals_prompt_executions(:one)
      execution.update_column(:judge_message, "{}")
      execution.reload
      execution.update(judge_message: {})

      assert_nil execution.judge_message
      assert_nil execution.reload.judge_message
    end

    test "should normalize empty array judge_message to nil" do
      execution = ruby_llm_evals_prompt_executions(:one)
      execution.update_column(:judge_message, "[]")
      execution.reload
      execution.update(judge_message: [])

      assert_nil execution.judge_message
      assert_nil execution.reload.judge_message
    end

    test "should normalize empty string judge_message to nil" do
      execution = ruby_llm_evals_prompt_executions(:one)
      execution.update_column(:judge_message, '""')
      execution.reload
      execution.update(judge_message: "")

      assert_nil execution.judge_message
      assert_nil execution.reload.judge_message
    end

    test "should not normalize judge_message with data" do
      execution = ruby_llm_evals_prompt_executions(:five)

      assert_not_nil execution.judge_message
      assert_equal true, execution.judge_message["passed"]
      assert_equal "Correctly identifies Paris as the capital of France", execution.judge_message["reasoning"]
    end

    test "judge_cost should return 0.0 when judge_model is blank" do
      execution = ruby_llm_evals_prompt_executions(:one)
      execution.update_columns(judge_model: nil, judge_provider: nil, judge_input: 100, judge_output: 50)

      assert_equal 0.0, execution.judge_cost
    end

    test "judge_cost should return 0.0 for local judge providers" do
      execution = ruby_llm_evals_prompt_executions(:one)
      execution.update_columns(
        judge_model: "llama3.2",
        judge_provider: "ollama",
        judge_input: 100,
        judge_output: 50
      )

      assert_equal 0.0, execution.judge_cost
    end

    test "judge_cost should calculate correctly for paid API judge providers" do
      execution = ruby_llm_evals_prompt_executions(:one)
      execution.update_columns(
        judge_model: "gemini-2.0-flash-001",
        judge_provider: "gemini",
        judge_input: 1000,
        judge_output: 100
      )

      # Cost should be calculated based on gemini pricing
      assert execution.judge_cost > 0.0
    end

    test "judge_cost should return 0.0 when judge_input and judge_output are nil" do
      execution = ruby_llm_evals_prompt_executions(:one)
      execution.update_columns(
        judge_model: "gemini-2.0-flash-001",
        judge_provider: "gemini",
        judge_input: nil,
        judge_output: nil
      )

      assert_equal 0.0, execution.judge_cost
    end

    test "total_cost should sum cost and judge_cost" do
      execution = ruby_llm_evals_prompt_executions(:one)
      execution.update_columns(
        input: 1500,
        output: 20,
        judge_model: "gemini-2.0-flash-001",
        judge_provider: "gemini",
        judge_input: 1000,
        judge_output: 100
      )

      base_cost = execution.cost
      judge_cost = execution.judge_cost

      assert base_cost > 0.0
      assert judge_cost > 0.0
      assert_equal (base_cost + judge_cost).round(4), execution.total_cost
    end

    test "total_cost should equal cost when there is no judge_cost" do
      execution = ruby_llm_evals_prompt_executions(:one)
      execution.update_columns(
        input: 1500,
        output: 20,
        judge_model: nil,
        judge_provider: nil,
        judge_input: nil,
        judge_output: nil
      )

      assert_equal execution.cost, execution.total_cost
    end

    test "cost should include thinking tokens in calculation" do
      execution = ruby_llm_evals_prompt_executions(:one)

      execution.update_columns(
        input: 1000,
        output: 100,
        thinking: 500
      )

      model, provider = RubyLLM.models.resolve(execution.run.model, provider: execution.run.provider)
      cost = (
        execution.input / 1_000_000.0 * model.input_price_per_million +
        execution.output / 1_000_000.0 * model.output_price_per_million +
        execution.thinking / 1_000_000.0 * model.output_price_per_million
      ).round(4)

      assert_equal cost, execution.cost
    end

    test "judge_cost should include judge_thinking tokens in calculation" do
      execution = ruby_llm_evals_prompt_executions(:one)

      execution.update_columns(
        judge_model: "gemini-2.0-flash-001",
        judge_provider: "gemini",
        judge_input: 1000,
        judge_output: 100,
        judge_thinking: 200
      )

      model, provider = RubyLLM.models.resolve(execution.judge_model, provider: execution.judge_provider)
      judge_cost = (
        execution.judge_input / 1_000_000.0 * model.input_price_per_million +
        execution.judge_output / 1_000_000.0 * model.output_price_per_million +
        execution.judge_thinking / 1_000_000.0 * model.output_price_per_million
      ).round(4)

      assert_equal judge_cost, execution.judge_cost
    end
  end
end
