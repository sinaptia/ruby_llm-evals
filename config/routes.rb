RubyLLM::Evals::Engine.routes.draw do
  resources :runs, only: %i[destroy index show] do
    resource :pin, only: %i[create destroy], module: :runs
  end

  resources :prompt_executions, only: [] do
    scope module: :prompt_executions do
      resource :failure, only: %i[create]
      resource :passage, only: %i[create]
      resource :retry, only: %i[create]
    end
  end

  resources :prompts do
    resources :runs, only: %i[create]

    scope module: :prompts do
      resource :comparison, only: %i[show]
    end
  end

  root to: "prompts#index"
end
