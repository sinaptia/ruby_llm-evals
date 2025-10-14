PromptBench::Engine.routes.draw do
  resources :prompts do
    resources :eval_results, only: %i[create destroy index show] do
      resources :prompt_executions, only: [] do
        member do
          patch :toggle
        end
      end
    end
  end

  root to: "prompts#index"
end
