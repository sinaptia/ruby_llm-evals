require "importmap-rails"
require "stimulus-rails"
require "turbo-rails"

module PromptBench
  class Engine < ::Rails::Engine
    isolate_namespace PromptBench

    initializer "prompt_bench.assets" do |app|
      # Add engine asset paths so Sprockets can find individual files
      app.config.assets.paths << root.join("app/assets/stylesheets")
      app.config.assets.paths << root.join("app/assets/images")

      # Precompile individual CSS files instead of using manifest
      # (avoids manifest processing issues when main app uses Vite)
      app.config.assets.precompile += %w[
        prompt_bench/application.css
        prompt_bench/bulma.min.css
      ]
    end

    initializer "prompt_bench.importmap", after: "importmap" do |app|
      PromptBench.importmap.draw(root.join("config/importmap.rb"))
      PromptBench.importmap.cache_sweeper(watches: root.join("app/javascript"))

      ActiveSupport.on_load(:action_controller_base) do
        before_action { PromptBench.importmap.cache_sweeper.execute_if_updated }
      end
    end
  end
end
