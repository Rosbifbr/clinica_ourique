require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_params = {
      name: "New User",
      email: "newuser@example.com",
      password: "password123",
      password_confirmation: "password123"
    }
    # Example existing user for update/delete tests if needed later
    @existing_user = users(:one) # Assumes a fixture named 'one' exists in users.yml
    sign_in_as(@existing_user) # Sign in the user
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { user: @user_params }
    end
    assert_redirected_to user_url(User.last)
    assert_equal "User was successfully created.", flash[:notice]
  end

  test "should not create user with invalid email" do
    assert_no_difference("User.count") do
      post users_url, params: { user: @user_params.merge(email: "invalid") }
    end
    assert_response :unprocessable_entity # Or :success if re-rendering :new template
    assert_select "div.alert" # Check for error messages rendering
  end

  test "should not create user with password mismatch" do
    assert_no_difference("User.count") do
      post users_url, params: { user: @user_params.merge(password_confirmation: "wrong") }
    end
    assert_response :unprocessable_entity
    assert_select "div.alert"
  end

  # Basic show test (assuming user :one from fixtures)
  test "should show user" do
    get user_url(@existing_user)
    assert_response :success
  end

  # Basic edit test
  test "should get edit" do
    # For edit, typically a user should be logged in.
    # This test might need to be expanded if authentication is enforced on edit.
    # For now, assuming no auth for simplicity of basic CRUD.
    get edit_user_url(@existing_user)
    assert_response :success
  end

  # Basic update test
  test "should update user" do
    patch user_url(@existing_user), params: { user: { name: "Updated Name" } }
    assert_redirected_to user_url(@existing_user)
    @existing_user.reload
    assert_equal "Updated Name", @existing_user.name
    assert_equal "User was successfully updated.", flash[:notice]
  end

  # Basic destroy test
  test "should destroy user" do
    assert_difference("User.count", -1) do
      delete user_url(@existing_user)
    end
    assert_redirected_to users_path # Or root_path depending on controller logic
    assert_equal "User was successfully destroyed.", flash[:notice]
  end
end
