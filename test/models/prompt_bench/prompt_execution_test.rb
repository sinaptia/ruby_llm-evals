require "test_helper"

module PromptBench
  class PromptExecutionTest < ActiveSupport::TestCase
    test "should be valid with required attributes" do
      execution = PromptExecution.new(
        sample: prompt_bench_samples(:one),
        run: prompt_bench_runs(:one),
        eval_type: "exact",
        expected_output: "test",
        message: "test"
      )
      assert execution.valid?
    end

    test "should require eval_type when manually set" do
      execution = prompt_bench_prompt_executions(:one)
      execution.eval_type = nil
      assert_not execution.valid?
    end

    test "should copy sample attributes on create" do
      # Test via fixtures - the fixture should have copied attributes from sample
      execution = prompt_bench_prompt_executions(:one)
      sample = execution.sample

      assert_equal sample.eval_type, execution.eval_type
      assert_equal sample.expected_output, execution.expected_output
      assert_equal sample.variables, execution.variables
    end

    test "cost should return 0.0 for local providers" do
      execution = prompt_bench_prompt_executions(:two)

      assert_equal "ollama", execution.run.provider
      assert_equal 0.0, execution.cost
    end

    test "cost should calculate correctly for paid API providers" do
      execution = prompt_bench_prompt_executions(:one)

      # Fixture has gemini provider with input: 1500, output: 20
      assert_equal "gemini", execution.run.provider
      assert_equal 1500, execution.input
      assert_equal 20, execution.output

      # Cost should be calculated based on gemini pricing
      assert execution.cost > 0.0
    end

    test "cost should return 0.0 when input and output are nil" do
      execution = PromptExecution.new(
        sample: prompt_bench_samples(:one),
        run: prompt_bench_runs(:one),
        eval_type: "exact",
        expected_output: "test",
        message: "test",
        input: nil,
        output: nil
      )

      assert_equal 0.0, execution.cost
    end

    test "should track input tokens" do
      execution = prompt_bench_prompt_executions(:one)

      assert_not_nil execution.input
      assert execution.input > 0
    end

    test "should track output tokens" do
      execution = prompt_bench_prompt_executions(:one)

      assert_not_nil execution.output
      assert execution.output > 0
    end

    test "execute should create prompt execution with API response" do
      VCR.use_cassette("prompt_execution_test_execute_exact_match") do
        sample = prompt_bench_samples(:one)
        run = prompt_bench_runs(:one)

        assert_difference "PromptExecution.count", 1 do
          PromptExecution.execute(sample:, run:)
        end

        execution = PromptExecution.last
        assert_equal sample, execution.sample
        assert_equal run, execution.run
        assert_not_nil execution.message
        assert_not_nil execution.input
        assert_not_nil execution.output
      end
    end

    test "execute should copy variables from sample" do
      VCR.use_cassette("prompt_execution_test_execute_with_variables") do
        sample = prompt_bench_samples(:two)
        run = prompt_bench_runs(:two)

        PromptExecution.execute(sample:, run:)

        execution = PromptExecution.last
        assert_equal sample.variables, execution.variables
      end
    end

    test "should copy file attachments from sample on create" do
      sample = prompt_bench_samples(:one)
      run = prompt_bench_runs(:one)

      # Attach a file to sample
      sample.files.attach(
        io: StringIO.new("test file content"),
        filename: "test.txt",
        content_type: "text/plain"
      )

      execution = PromptExecution.create(sample:, run:)

      assert_equal sample.files.count, execution.files.count
      assert_equal "test.txt", execution.files.first.filename.to_s
    end

    test "should normalize empty hash variables to nil" do
      execution = PromptExecution.create!(
        sample: prompt_bench_samples(:one),
        run: prompt_bench_runs(:one)
      )
      execution.update_column(:variables, "{}")
      execution.reload
      execution.update(variables: {})

      assert_nil execution.variables
      assert_nil execution.reload.variables
    end

    test "should normalize empty array variables to nil" do
      execution = PromptExecution.create!(
        sample: prompt_bench_samples(:one),
        run: prompt_bench_runs(:one)
      )
      execution.update_column(:variables, "[]")
      execution.reload
      execution.update(variables: [])

      assert_nil execution.variables
      assert_nil execution.reload.variables
    end

    test "should normalize empty string variables to nil" do
      execution = PromptExecution.create!(
        sample: prompt_bench_samples(:one),
        run: prompt_bench_runs(:one)
      )
      execution.update_column(:variables, '""')
      execution.reload
      execution.update(variables: "")

      assert_nil execution.variables
      assert_nil execution.reload.variables
    end

    test "should not normalize variables with data" do
      execution = PromptExecution.create!(
        sample: prompt_bench_samples(:one),
        run: prompt_bench_runs(:one)
      )
      execution.update(variables: { "key" => "value" })

      assert_equal({ "key" => "value" }, execution.variables)
      assert_equal({ "key" => "value" }, execution.reload.variables)
    end
  end
end
