require "activemodel/validations/json_validator"
require "liquid"
require "ruby_llm"
require "ruby_llm/evals/engine"
require "ruby_llm/evals/version"
require "ruby_llm/schema"

module RubyLLM
  module Evals
    mattr_accessor :importmap, default: Importmap::Map.new
  end
end
