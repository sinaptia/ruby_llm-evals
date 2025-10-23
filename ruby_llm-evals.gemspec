require_relative "lib/ruby_llm/evals/version"

Gem::Specification.new do |spec|
  spec.name        = "ruby_llm-evals"
  spec.version     = RubyLLM::Evals::VERSION
  spec.authors     = [ "Patricio Mac Adden", "Fernando Martinez" ]
  spec.email       = [ "patricio.macadden@sinaptia.dev", "fernando.martinez@sinaptia.dev" ]
  spec.homepage    = "https://github.com/sinaptia/ruby_llm-evals"
  spec.summary     = "LLM evaluation engine for Rails."
  spec.description = "LLM evaluation engine for Rails."

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "importmap-rails"
  spec.add_dependency "rails", ">= 7.0.0"
  spec.add_dependency "ruby_llm"
  spec.add_dependency "ruby_llm-schema"
  spec.add_dependency "stimulus-rails"
  spec.add_dependency "turbo-rails"
end
