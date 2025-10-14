Rails.application.routes.draw do
  mount PromptBench::Engine => "/prompt_bench"
end
