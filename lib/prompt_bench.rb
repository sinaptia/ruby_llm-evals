require "activemodel/validations/json_validator"
require "prompt_bench/version"
require "prompt_bench/engine"
require "ruby_llm"
require "ruby_llm/schema"

module PromptBench
  include ActiveSupport::Configurable

  config_accessor :importmap, default: Importmap::Map.new
end
