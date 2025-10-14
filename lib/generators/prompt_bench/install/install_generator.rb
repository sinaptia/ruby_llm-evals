module PromptBench
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    def create_migrations
      generate "migration", "CreatePromptBenchPrompts", "name:string!:uniq slug:string!:uniq provider:string! model:string! instructions:text message:text!", "--force"
      generate "migration", "CreatePromptBenchEvalExamples", "prompt_bench_prompt:references eval_type:string! expected_output:text variables:json", "--force"
      generate "migration", "CreatePromptBenchEvalResults", "prompt_bench_prompt:references active_job_id:string! started_at:timestamp ended_at:timestamp provider:string! model:string! instructions:text message:text!", "--force"
      generate "migration", "CreatePromptBenchPromptExecutions", "prompt_bench_eval_example:references prompt_bench_eval_result:references eval_type:string! expected_output:text variables:json input:integer output:integer message:text passed:boolean", "--force"
    end
  end
end
