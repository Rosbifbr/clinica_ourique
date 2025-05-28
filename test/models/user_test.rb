require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should have name" do
    user = User.new(email: "test@example.com", password: "password", password_confirmation: "password")
    assert_not user.valid?, "User should be invalid without a name"
    assert user.errors[:name].any?, "Should have an error on name"
  end

  test "should have email" do
    user = User.new(name: "Test User", password: "password", password_confirmation: "password")
    assert_not user.valid?, "User should be invalid without an email"
    assert user.errors[:email].any?, "Should have an error on email"
  end

  test "email should be unique" do
    existing_user = users(:one) # From fixtures
    user = User.new(name: "Another User", email: existing_user.email, password: "password", password_confirmation: "password")
    assert_not user.valid?, "User should be invalid with a duplicate email"
    assert user.errors[:email].any?, "Should have an error on email for uniqueness"
  end

  test "has secure password" do
    # Check if password_digest attribute exists
    assert User.new.respond_to?(:password_digest), "User should have a password_digest attribute"

    # Valid user with matching password and confirmation
    user_valid = User.new(name: "Test User", email: "valid@example.com", password: "password", password_confirmation: "password")
    assert user_valid.valid?, "User should be valid with matching password and confirmation. Errors: #{user_valid.errors.full_messages.join(", ")}"

    # Invalid user with mismatched password and confirmation
    user_mismatch = User.new(name: "Test User", email: "mismatch@example.com", password: "password", password_confirmation: "different")
    assert_not user_mismatch.valid?, "User should be invalid with mismatched password and confirmation"
    assert user_mismatch.errors[:password_confirmation].any?, "Should have an error on password_confirmation for mismatch"
  end

  test "email should be saved in lower-case" do
    email_with_uppercase = "TEST@EXAMPLE.COM"
    user = User.create(name: "Test User", email: email_with_uppercase, password: "password", password_confirmation: "password")
    assert_equal email_with_uppercase.downcase, user.email, "Email should be saved in lower-case"
  end
end
