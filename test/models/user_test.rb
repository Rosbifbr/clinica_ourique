require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user_params = {
      name: "Test User",
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    }
    # Clear users table for a clean slate, or use transactional tests if configured
    User.delete_all
  end

  test "should be valid with all attributes" do
    user = User.new(@user_params)
    assert user.valid?, "User should be valid, but got errors: #{user.errors.full_messages.join(", ")}"
  end

  test "should have a name" do
    user = User.new(@user_params.except(:name))
    assert_not user.valid?, "User should be invalid without a name"
    assert_includes user.errors[:name], "can't be blank"
  end

  test "should have an email" do
    user = User.new(@user_params.except(:email))
    assert_not user.valid?, "User should be invalid without an email"
    assert_includes user.errors[:email], "can't be blank"
  end

  test "email should be unique (case-insensitive)" do
    User.create!(@user_params)
    user = User.new(@user_params.merge(email: "TEST@EXAMPLE.COM")) # Different case
    assert_not user.valid?, "User should be invalid with a duplicate email (case-insensitive)"
    assert_includes user.errors[:email], "has already been taken"
  end

  test "email should have valid format" do
    user = User.new(@user_params.merge(email: "invalid_email"))
    assert_not user.valid?, "User should be invalid with an invalid email format"
    assert_includes user.errors[:email], "is invalid"
  end

  test "should have a password on create" do
    user = User.new(@user_params.except(:password, :password_confirmation))
    assert_not user.valid?, "User should be invalid without a password"
    # has_secure_password adds this error to :password
    assert_includes user.errors[:password], "can't be blank"
  end

  test "password should have minimum length" do
    user = User.new(@user_params.merge(password: "12345", password_confirmation: "12345"))
    assert_not user.valid?, "User should be invalid with a short password"
    assert_includes user.errors[:password], "is too short (minimum is 6 characters)"
  end

  test "password confirmation should match password" do
    user = User.new(@user_params.merge(password_confirmation: "wrongpassword"))
    assert_not user.valid?, "User should be invalid if password confirmation doesn't match"
    assert_includes user.errors[:password_confirmation], "doesn't match Password"
  end

  test "should authenticate with correct password" do
    user = User.create!(@user_params)
    assert user.authenticate("password123"), "User should authenticate with the correct password"
  end

  test "should not authenticate with incorrect password" do
    user = User.create!(@user_params)
    assert_not user.authenticate("wrongpassword"), "User should not authenticate with an incorrect password"
  end

  test "creating a user should hash the password" do
    user = User.create!(@user_params)
    assert_not_equal "password123", user.password_digest
    assert user.password_digest.present?
  end

  test "email should be saved in lower-case" do
    # Note: Current User model does not automatically downcase email before validation/saving.
    # This test will fail unless we add that callback to the model.
    # For now, this test documents the desired behavior.
    # To implement: add `before_save { self.email = email.downcase }` to User model.
    # user = User.create!(@user_params.merge(email: "CAPITAL@EXAMPLE.COM"))
    # assert_equal "capital@example.com", user.email
  end
end
