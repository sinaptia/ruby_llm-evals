module PromptBench
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path("templates", __dir__)

    def self.next_migration_number(path)
      next_migration_number = current_migration_number(path) + 1
      ActiveRecord::Migration.next_migration_number(next_migration_number)
    end

    def create_migrations
      migration_template "create_prompt_bench_prompts.rb.tt", "db/migrate/create_prompt_bench_prompts.rb"
      migration_template "create_prompt_bench_eval_examples.rb.tt", "db/migrate/create_prompt_bench_eval_examples.rb"
      migration_template "create_prompt_bench_eval_results.rb.tt", "db/migrate/create_prompt_bench_eval_results.rb"
      migration_template "create_prompt_bench_prompt_executions.rb.tt", "db/migrate/create_prompt_bench_prompt_executions.rb"
    end
  end
end
