require "test_helper"

class JsonArrayValidatorTest < ActiveSupport::TestCase
  class TestModel
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :data

    validates_with ActiveModel::Validations::JsonArrayValidator, attributes: [ :data ]
  end

  test "allows nil values" do
    model = TestModel.new(data: nil)
    assert model.valid?
  end

  test "allows blank values" do
    model = TestModel.new(data: "")
    assert model.valid?
  end

  test "parses valid JSON array string" do
    model = TestModel.new(data: '["item1", "item2"]')
    model.valid?
    assert_equal([ "item1", "item2" ], model.data)
    assert model.valid?
  end

  test "allows Array objects directly" do
    model = TestModel.new(data: [ "item1", "item2" ])
    assert model.valid?
    assert_equal([ "item1", "item2" ], model.data)
  end

  test "adds error for JSON object string" do
    model = TestModel.new(data: '{"key": "value"}')
    assert_not model.valid?
    assert_includes model.errors[:data], "must be a JSON array"
  end

  test "adds error for Hash objects" do
    model = TestModel.new(data: { "key" => "value" })
    assert_not model.valid?
    assert_includes model.errors[:data], "must be a JSON array"
  end

  test "adds error for invalid JSON string" do
    model = TestModel.new(data: "[invalid json]")
    assert_not model.valid?
    assert_includes model.errors[:data], "is invalid JSON"
  end

  test "handles arrays of objects" do
    json_string = '[{"name": "John"}, {"name": "Jane"}]'
    model = TestModel.new(data: json_string)
    model.valid?
    assert model.valid?
    assert_equal([ { "name" => "John" }, { "name" => "Jane" } ], model.data)
  end

  test "handles empty array" do
    model = TestModel.new(data: "[]")
    model.valid?
    assert model.valid?
    assert_equal([], model.data)
  end

  test "handles arrays with mixed types" do
    json_string = '[1, "string", true, null, {"key": "value"}]'
    model = TestModel.new(data: json_string)
    model.valid?
    assert model.valid?
    assert_equal([ 1, "string", true, nil, { "key" => "value" } ], model.data)
  end

  test "handles nested arrays" do
    json_string = "[[1, 2], [3, 4], [5, 6]]"
    model = TestModel.new(data: json_string)
    model.valid?
    assert model.valid?
    assert_equal([ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ] ], model.data)
  end

  test "adds error for primitive JSON values" do
    [ '"string"', "123", "true", "null" ].each do |value|
      model = TestModel.new(data: value)
      assert_not model.valid?, "Expected #{value} to be invalid"
      assert_includes model.errors[:data], "must be a JSON array"
    end
  end
end
