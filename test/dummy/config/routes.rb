Rails.application.routes.draw do
  mount RubyLLM::Evals::Engine => "/evals"
end
