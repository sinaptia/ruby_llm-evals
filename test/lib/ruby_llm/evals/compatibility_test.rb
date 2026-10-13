require "test_helper"

module RubyLLM::Evals
  class CompatibilityTest < ActiveSupport::TestCase
    test "provider options take precedence over legacy params" do
      chat = Object.new
      chat.define_singleton_method(:with_provider_options) { |params| params }
      chat.define_singleton_method(:with_params) { |**| raise "legacy API used" }
      assert_equal({ "limit" => 2 }, Compatibility.with_params(chat, { "limit" => 2 }))
    end

    test "legacy params receive keyword arguments" do
      chat = Object.new
      chat.define_singleton_method(:with_params) { |**params| params }
      assert_equal({ "limit" => 2 }, Compatibility.with_params(chat, { "limit" => 2 }))
    end

    test "structured tokens exclude thinking from visible output" do
      response = Struct.new(:tokens).new(Struct.new(:input, :output, :thinking).new(10, 8, 3))
      assert_equal 10, Compatibility.tokens(response, :input)
      assert_equal 3, Compatibility.tokens(response, :thinking)
      assert_equal (Gem::Version.new(RubyLLM::VERSION) >= Gem::Version.new("2.0") ? 5 : 8), Compatibility.output_tokens(response)
      response.tokens.output = nil
      assert_nil Compatibility.output_tokens(response)
      response.tokens.output = 8
      response.tokens.thinking = nil
      assert_equal 8, Compatibility.output_tokens(response)
    end

    test "flat token access supports legacy responses" do
      response = Struct.new(:input_tokens, :output_tokens, :thinking_tokens).new(10, 8, 3)
      assert_equal 10, Compatibility.tokens(response, :input)
      assert_equal 3, Compatibility.tokens(response, :thinking)
      assert_equal (Gem::Version.new(RubyLLM::VERSION) >= Gem::Version.new("2.0") ? 5 : 8), Compatibility.output_tokens(response)
      response.output_tokens = nil
      assert_nil Compatibility.output_tokens(response)
    end

    test "model ids support both APIs" do
      assert_equal "old", Compatibility.model_id(Struct.new(:model_id).new("old"))
      assert_equal "new", Compatibility.model_id(Struct.new(:model).new("new"))
    end

    test "prices support both APIs and missing prices" do
      model = Struct.new(:input_price_per_million, :output_price_per_million).new(2, nil)
      assert_equal 2.0, Compatibility.price(model, :input)
      assert_equal 0.0, Compatibility.price(model, :output)
      model.define_singleton_method(:price) { |kind| kind == :input ? 3 : nil }
      assert_equal 3.0, Compatibility.price(model, :input)
      assert_equal 0.0, Compatibility.price(model, :output)
    end
  end
end
