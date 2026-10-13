# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Thinking support. [#47](https://github.com/sinaptia/ruby_llm-evals/pull/47) [@patriciomacadden](https://github.com/patriciomacadden)
- Pinned runs. [#52](https://github.com/sinaptia/ruby_llm-evals/pull/52) [@patriciomacadden](https://github.com/patriciomacadden)
- Add `RubyLLM::Evals::Prompt#to_chat` method to build configured `RubyLLM::Chat` objects without immediate execution. [#53](https://github.com/sinaptia/ruby_llm-evals/pull/53) [@patriciomacadden](https://github.com/patriciomacadden)

### Changed

- Support RubyLLM 1.x and 2.x with a compatibility layer for provider options, token usage, model IDs, and pricing, preserving thinking-token cost accounting. [#90](https://github.com/sinaptia/ruby_llm-evals/pull/90) [@patriciomacadden](https://github.com/patriciomacadden)
- Cost and judge cost contemplate thinking tokens. [#51](https://github.com/sinaptia/ruby_llm-evals/pull/51) [@patriciomacadden](https://github.com/patriciomacadden)
- Show newer runs first. [#54](https://github.com/sinaptia/ruby_llm-evals/pull/54) [@patriciomacadden](https://github.com/patriciomacadden)

### Fixed

- Return zero cost for models missing from the registry or without pricing instead of crashing run pages, including judge costs. [#91](https://github.com/sinaptia/ruby_llm-evals/pull/91) [@patriciomacadden](https://github.com/patriciomacadden)
- Add missing assets to precompilation when using sprockets. [@patriciomacadden](https://github.com/patriciomacadden)
- Fix pagination not preserving filters. [#50](https://github.com/sinaptia/ruby_llm-evals/pull/50) [@patriciomacadden](https://github.com/patriciomacadden)
- Remove pinned_at partial index as it's having some issues in mysql. [#55](https://github.com/sinaptia/ruby_llm-evals/pull/55) [@patriciomacadden](https://github.com/patriciomacadden)
