require "importmap-rails"
require "stimulus-rails"
require "turbo-rails"

module RubyLLM
  module Evals
    class Engine < ::Rails::Engine
      isolate_namespace RubyLLM::Evals

      INFLECTION_OVERRIDES = { "ruby_llm" => "RubyLLM" }.freeze

      initializer "ruby_llm_evals.inflector", after: "ruby_llm.inflections", before: :set_autoload_paths do
        ActiveSupport::Inflector.inflections(:en) do |inflections|
          # The RubyLLM gem registers "RubyLLM" as an acronym in its railtie,
          # which breaks underscore conversion (RubyLLM.underscore => "rubyllm").
          # We need to remove it and use "LLM" as an acronym instead for proper conversion:
          # * "ruby_llm".camelize => "RubyLLM" (not "RubyLlm")
          # * "RubyLLM".underscore => "ruby_llm" (not "rubyllm")
          inflections.acronyms.delete("rubyllm")
          inflections.acronym("LLM")
        end

        Rails.autoloaders.each do |loader|
          loader.inflector.inflect(INFLECTION_OVERRIDES)
        end
      end

      initializer "ruby_llm_evals.assets" do |app|
        app.config.assets.paths << root.join("app/assets/stylesheets")
        app.config.assets.paths << root.join("app/assets/images")
        app.config.assets.paths << root.join("app/javascript")

        app.config.assets.precompile += %w[
          ruby_llm/evals/application.css
          ruby_llm/evals/bulma.min.css
          ruby_llm/evals/application.js
          ruby_llm/evals/controllers/application.js
          ruby_llm/evals/controllers/index.js
          ruby_llm/evals/controllers/eval_type_selector_controller.js
          ruby_llm/evals/controllers/file_input_controller.js
          ruby_llm/evals/controllers/json_editor_controller.js
          ruby_llm/evals/controllers/provider_model_controller.js
          ruby_llm/evals/controllers/schema_selector_controller.js
        ]
      end

      initializer "ruby_llm_evals.importmap", after: "importmap" do |app|
        RubyLLM::Evals.importmap.draw(root.join("config/importmap.rb"))
        RubyLLM::Evals.importmap.cache_sweeper(watches: root.join("app/javascript"))

        ActiveSupport.on_load(:action_controller_base) do
          before_action { RubyLLM::Evals.importmap.cache_sweeper.execute_if_updated }
        end
      end
    end
  end
end
