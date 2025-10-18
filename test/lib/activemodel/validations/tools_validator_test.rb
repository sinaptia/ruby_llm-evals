require "test_helper"

class ToolsValidatorTest < ActiveSupport::TestCase
  class TestTool
  end

  class AnotherTestTool
  end

  class TestModel
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :tools

    validates_with ActiveModel::Validations::ToolsValidator, attributes: [ :tools ]
  end

  test "allows nil values" do
    model = TestModel.new(tools: nil)
    assert model.valid?
  end

  test "allows blank values" do
    model = TestModel.new(tools: "")
    assert model.valid?
  end

  test "allows empty array" do
    model = TestModel.new(tools: [])
    assert model.valid?
  end

  test "parses valid JSON array of tool names" do
    model = TestModel.new(tools: '["String", "Integer"]')
    model.valid?
    assert model.valid?
    assert_equal([ "String", "Integer" ], model.tools)
  end

  test "allows array of valid tool class names" do
    model = TestModel.new(tools: [ "String", "Integer" ])
    assert model.valid?
  end

  test "adds error for undefined tool class" do
    model = TestModel.new(tools: [ "NonExistentTool" ])
    assert_not model.valid?
    assert_includes model.errors[:tools].first, "NonExistentTool"
    assert_match(/not defined/, model.errors[:tools].first)
  end

  test "adds error for multiple undefined tool classes" do
    model = TestModel.new(tools: [ "NonExistentTool1", "NonExistentTool2" ])
    assert_not model.valid?
    assert_includes model.errors[:tools].first, "NonExistentTool1"
    assert_includes model.errors[:tools].first, "NonExistentTool2"
    assert_match(/not defined/, model.errors[:tools].first)
  end

  test "adds error for mix of valid and invalid tool classes" do
    model = TestModel.new(tools: [ "String", "NonExistentTool" ])
    assert_not model.valid?
    assert_includes model.errors[:tools].first, "NonExistentTool"
    assert_not_includes model.errors[:tools].first, "String"
  end

  test "adds error for invalid JSON string" do
    model = TestModel.new(tools: "[invalid json]")
    assert_not model.valid?
    assert_includes model.errors[:tools], "is invalid JSON"
  end

  test "adds error for non-array JSON" do
    model = TestModel.new(tools: '{"key": "value"}')
    assert_not model.valid?
    assert_includes model.errors[:tools], "must be a JSON array"
  end

  test "adds error for non-array value" do
    model = TestModel.new(tools: { "key" => "value" })
    assert_not model.valid?
    assert_includes model.errors[:tools], "must be a JSON array"
  end

  test "handles tools with nested module names" do
    model = TestModel.new(tools: [ "ToolsValidatorTest::TestTool" ])
    assert model.valid?
  end

  test "parses JSON string with valid tool names" do
    json_string = '["ToolsValidatorTest::TestTool", "ToolsValidatorTest::AnotherTestTool"]'
    model = TestModel.new(tools: json_string)
    model.valid?
    assert model.valid?
    assert_equal([
      "ToolsValidatorTest::TestTool",
      "ToolsValidatorTest::AnotherTestTool"
    ], model.tools)
  end

  test "allows built-in Ruby class names" do
    model = TestModel.new(tools: [ "String", "Integer", "Hash", "Array" ])
    assert model.valid?
  end
end
