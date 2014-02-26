require 'test_helper'

class ApiVersionTest < ActiveSupport::TestCase
  test "exact match is allowed" do
    assert ApiVersion.allowed?('DEVELOPMENT',['DEVELOPMENT'])
  end
  test "mismatch is disallowed" do
    assert ApiVersion.allowed?('OLD',['DEVELOPMENT']).blank?
  end
  test "version tag exact match is allowed" do
    assert ApiVersion.allowed?('v1.5-6-hash',['v1.5-6-hash'])
  end
  test "minor upgrade is allowed" do
    assert ApiVersion.allowed?('v1.5-7-hxxh',['v1.5-6-hash'])
  end
  test "major upgrade is disallowed" do
    assert ApiVersion.allowed?('v1.6-6-xxsh',['v1.5-6-hash']).blank?
  end
  test "more major upgrade is disallowed" do
    assert ApiVersion.allowed?('v2.5-6-xasx',['v1.5-6-hash']).blank?
  end
  test "downgrade not allowed" do
    assert ApiVersion.allowed?('v1.5-5-xasx',['v1.5-6-hash']).blank?
  end
  test "url for development is null" do
    assert_equal nil, ApiVersion.url("ios/DEVELOPMENT")
  end
  test "url for old is present" do
    assert ApiVersion.url("ios/OLD").present?
  end
  test "errors for present is blank" do
    errors = ActiveModel::Errors.new(nil)
    ApiVersion.check(errors, "ios/DEVELOPMENT")
    assert errors.empty?
  end
  test "errors for old version is recorded" do
    errors = ActiveModel::Errors.new(nil)
    ApiVersion.check(errors, "ios/old")
    assert_equal 1, errors.size
  end
  test "errors for invalid version is recorded" do
    errors = ActiveModel::Errors.new(nil)
    ApiVersion.check(errors, "not a real version")
    assert_equal 1, errors.size
  end
  test "errors for unknown platform" do
    errors = ActiveModel::Errors.new(nil)
    ApiVersion.check(errors, "orange/monkeys")
    assert_equal 1, errors.size
  end
  test "no url for unknown platform" do
    assert ApiVersion.url("orange/monkeys").blank?
  end
end
