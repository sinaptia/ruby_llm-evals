require "test_helper"
require "generators/prompt_bench/install/install_generator"

module PromptBench
  class InstallGeneratorTest < Rails::Generators::TestCase
    tests InstallGenerator
    destination Rails.root.join("tmp/generators")
    setup :prepare_destination

    test "generates the migrations" do
      run_generator

      assert_migration "db/migrate/create_prompt_bench_prompts"
      assert_migration "db/migrate/create_prompt_bench_eval_examples"
      assert_migration "db/migrate/create_prompt_bench_eval_results"
      assert_migration "db/migrate/create_prompt_bench_prompt_executions"
    end
  end
end
