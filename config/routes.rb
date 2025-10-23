RubyLLM::Evals::Engine.routes.draw do
  resources :runs, only: %i[destroy index show]

  resources :prompt_executions, only: [] do
    member do
      patch :toggle
    end
  end

  resources :prompts do
    resources :runs, only: %i[create]
  end

  root to: "prompts#index"
end
