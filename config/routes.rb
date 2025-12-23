RubyLLM::Evals::Engine.routes.draw do
  resources :runs, only: %i[destroy index show]

  resources :prompt_executions, only: [] do
    member do
      patch :fail
      patch :pass
      patch :retry
    end
  end

  resources :prompts do
    resources :runs, only: %i[create]

    member do
      get :compare
    end
  end

  root to: "prompts#index"
end
