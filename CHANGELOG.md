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

- Cost and judge cost contemplate thinking tokens. [#51](https://github.com/sinaptia/ruby_llm-evals/pull/51) [@patriciomacadden](https://github.com/patriciomacadden)
- Show newer runs first. [#54](https://github.com/sinaptia/ruby_llm-evals/pull/54) [@patriciomacadden](https://github.com/patriciomacadden)

### Fixed

- Add missing assets to precompilation when using sprockets. [@patriciomacadden](https://github.com/patriciomacadden)
- Fix pagination not preserving filters. [#50](https://github.com/sinaptia/ruby_llm-evals/pull/50) [@patriciomacadden](https://github.com/patriciomacadden)
