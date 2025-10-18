require "test_helper"

class JsonObjectValidatorTest < ActiveSupport::TestCase
  class TestModel
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :data

    validates_with ActiveModel::Validations::JsonObjectValidator, attributes: [ :data ]
  end

  test "allows nil values" do
    model = TestModel.new(data: nil)
    assert model.valid?
  end

  test "allows blank values" do
    model = TestModel.new(data: "")
    assert model.valid?
  end

  test "parses valid JSON object string" do
    model = TestModel.new(data: '{"key": "value"}')
    model.valid?
    assert_equal({ "key" => "value" }, model.data)
    assert model.valid?
  end

  test "allows Hash objects directly" do
    model = TestModel.new(data: { "key" => "value" })
    assert model.valid?
    assert_equal({ "key" => "value" }, model.data)
  end

  test "adds error for JSON array string" do
    model = TestModel.new(data: '["item1", "item2"]')
    assert_not model.valid?
    assert_includes model.errors[:data], "must be a JSON object"
  end

  test "adds error for Array objects" do
    model = TestModel.new(data: [ "item1", "item2" ])
    assert_not model.valid?
    assert_includes model.errors[:data], "must be a JSON object"
  end

  test "adds error for invalid JSON string" do
    model = TestModel.new(data: "{invalid json}")
    assert_not model.valid?
    assert_includes model.errors[:data], "is invalid JSON"
  end

  test "handles nested object structures" do
    json_string = '{"outer": {"inner": "value"}, "nested": {"key": "val"}}'
    model = TestModel.new(data: json_string)
    model.valid?
    assert model.valid?
    assert_equal({ "outer" => { "inner" => "value" }, "nested" => { "key" => "val" } }, model.data)
  end

  test "handles empty object" do
    model = TestModel.new(data: "{}")
    model.valid?
    assert model.valid?
    assert_equal({}, model.data)
  end

  test "handles objects with array values" do
    json_string = '{"items": [1, 2, 3], "name": "test"}'
    model = TestModel.new(data: json_string)
    model.valid?
    assert model.valid?
    assert_equal({ "items" => [ 1, 2, 3 ], "name" => "test" }, model.data)
  end

  test "adds error for primitive JSON values" do
    [ '"string"', "123", "true", "null" ].each do |value|
      model = TestModel.new(data: value)
      assert_not model.valid?, "Expected #{value} to be invalid"
      assert_includes model.errors[:data], "must be a JSON object"
    end
  end
end
