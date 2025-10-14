PromptBench::Engine.routes.draw do
  resources :eval_results, only: %i[destroy index show]

  resources :prompt_executions, only: [] do
    member do
      patch :toggle
    end
  end

  resources :prompts do
    resources :eval_results, only: %i[create]
  end

  root to: "prompts#index"
end
