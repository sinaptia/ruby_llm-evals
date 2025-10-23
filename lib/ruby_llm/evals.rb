require "activemodel/validations/json_validator"
require "ruby_llm"
require "ruby_llm/evals/engine"
require "ruby_llm/evals/version"
require "ruby_llm/schema"

module RubyLLM
  module Evals
    include ActiveSupport::Configurable

    config_accessor :importmap, default: Importmap::Map.new
  end
end
