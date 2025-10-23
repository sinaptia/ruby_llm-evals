pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@stimulus-components/rails-nested-form", to: "https://ga.jspm.io/npm:@stimulus-components/rails-nested-form@5.0.0/dist/stimulus-rails-nested-form.mjs", preload: true

pin "application", to: "ruby_llm/evals/application.js", preload: true
pin_all_from RubyLLM::Evals::Engine.root.join("app/javascript/ruby_llm/evals/controllers"), under: "controllers", to: "ruby_llm/evals/controllers"
