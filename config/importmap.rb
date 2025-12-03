pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@stimulus-components/auto-submit", to: "https://ga.jspm.io/npm:@stimulus-components/auto-submit@6.0.0/dist/stimulus-auto-submit.mjs"
pin "@stimulus-components/rails-nested-form", to: "https://ga.jspm.io/npm:@stimulus-components/rails-nested-form@5.0.0/dist/stimulus-rails-nested-form.mjs", preload: true

pin "ace-builds", to: "https://cdn.jsdelivr.net/npm/ace-builds@1.35.5/src-min-noconflict/ace.min.js", preload: true
pin "ace-mode-json", to: "https://cdn.jsdelivr.net/npm/ace-builds@1.35.5/src-min-noconflict/mode-json.min.js", preload: true
pin "ace-theme-github", to: "https://cdn.jsdelivr.net/npm/ace-builds@1.35.5/src-min-noconflict/theme-github.min.js", preload: true
pin "ace-theme-github-dark", to: "https://cdn.jsdelivr.net/npm/ace-builds@1.35.5/src-min-noconflict/theme-github_dark.min.js", preload: true

pin "application", to: "ruby_llm/evals/application.js", preload: true
pin_all_from RubyLLM::Evals::Engine.root.join("app/javascript/ruby_llm/evals/controllers"), under: "controllers", to: "ruby_llm/evals/controllers"
