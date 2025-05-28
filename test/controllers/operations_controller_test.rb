require "test_helper"

class OperationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as @user # Use shared helper
    @client = clients(:one) # Operations need a client
    @operation = operations(:one)
    # Ensure the fixture operation belongs to the fixture client
    @operation.update(client: @client)
  end

  test "should get index" do
    get operations_url
    assert_response :success
  end

  test "should get new" do
    get new_operation_url
    assert_response :success
  end

  test "should create operation" do
    assert_difference("Operation.count") do
      # Use @client.id for client_id
      post operations_url, params: { operation: { client_id: @client.id, cost: @operation.cost, date: @operation.date, description: "New Test Operation", status: @operation.status } }
    end

    assert_redirected_to operation_url(Operation.last)
  end

  test "should show operation" do
    get operation_url(@operation)
    assert_response :success
  end

  test "should get edit" do
    get edit_operation_url(@operation)
    assert_response :success
  end

  test "should update operation" do
    patch operation_url(@operation), params: { operation: { description: "Updated Operation Description" } }
    assert_redirected_to operation_url(@operation)
    @operation.reload
    assert_equal "Updated Operation Description", @operation.description
  end

  test "should destroy operation" do
    assert_difference("Operation.count", -1) do
      delete operation_url(@operation)
    end

    assert_redirected_to operations_url
  end

end
