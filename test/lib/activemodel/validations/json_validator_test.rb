require "test_helper"

class JsonValidatorTest < ActiveSupport::TestCase
  class TestModel
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :data

    validates_with ActiveModel::Validations::JsonValidator, attributes: [ :data ]
  end

  test "allows nil values" do
    model = TestModel.new(data: nil)
    assert model.valid?
  end

  test "allows blank values" do
    model = TestModel.new(data: "")
    assert model.valid?
  end

  test "parses valid JSON string to object" do
    model = TestModel.new(data: '{"key": "value"}')
    model.valid?
    assert_equal({ "key" => "value" }, model.data)
  end

  test "parses valid JSON array string" do
    model = TestModel.new(data: '["item1", "item2"]')
    model.valid?
    assert_equal([ "item1", "item2" ], model.data)
  end

  test "adds error for invalid JSON string" do
    model = TestModel.new(data: "{invalid json}")
    assert_not model.valid?
    assert_includes model.errors[:data], "is invalid JSON"
  end

  test "adds error for malformed JSON" do
    model = TestModel.new(data: '{"key": }')
    assert_not model.valid?
    assert_includes model.errors[:data], "is invalid JSON"
  end

  test "allows already parsed Hash objects" do
    model = TestModel.new(data: { "key" => "value" })
    assert model.valid?
    assert_equal({ "key" => "value" }, model.data)
  end

  test "allows already parsed Array objects" do
    model = TestModel.new(data: [ "item1", "item2" ])
    assert model.valid?
    assert_equal([ "item1", "item2" ], model.data)
  end

  test "handles nested JSON structures" do
    json_string = '{"outer": {"inner": "value"}, "array": [1, 2, 3]}'
    model = TestModel.new(data: json_string)
    model.valid?
    assert_equal({ "outer" => { "inner" => "value" }, "array" => [ 1, 2, 3 ] }, model.data)
  end

  test "handles JSON with special characters" do
    json_string = '{"message": "Hello \"World\""}'
    model = TestModel.new(data: json_string)
    model.valid?
    assert_equal({ "message" => 'Hello "World"' }, model.data)
  end

  test "handles JSON with unicode characters" do
    json_string = '{"emoji": "🚀", "text": "こんにちは"}'
    model = TestModel.new(data: json_string)
    model.valid?
    assert_equal({ "emoji" => "🚀", "text" => "こんにちは" }, model.data)
  end
end
