module PromptBench
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path("templates", __dir__)

    def self.next_migration_number(dirname)
      next_migration_number = current_migration_number(dirname) + 1
      ActiveRecord::Migration.next_migration_number(next_migration_number)
    end

    def create_migrations
      migration_template "db/migrate/create_prompt_bench_prompts.rb", "db/migrate/create_prompt_bench_prompts.rb", force: true
      migration_template "db/migrate/create_prompt_bench_eval_examples.rb", "db/migrate/create_prompt_bench_eval_examples.rb", force: true
      migration_template "db/migrate/create_prompt_bench_eval_results.rb", "db/migrate/create_prompt_bench_eval_results.rb", force: true
      migration_template "db/migrate/create_prompt_bench_prompt_executions.rb", "db/migrate/create_prompt_bench_prompt_executions.rb", force: true
    end
  end
end
