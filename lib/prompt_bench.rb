require "activemodel/validations/json_validator"
require "activemodel/validations/json_array_validator"
require "activemodel/validations/json_object_validator"
require "activemodel/validations/tools_validator"
require "prompt_bench/version"
require "prompt_bench/engine"
require "ruby_llm"

module PromptBench
  include ActiveSupport::Configurable

  config_accessor :base_controller_class, default: "ApplicationController"
  config_accessor :importmap, default: Importmap::Map.new
end
