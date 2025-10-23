module RubyLLM
  module Evals
    class ApplicationRecord < ::ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
