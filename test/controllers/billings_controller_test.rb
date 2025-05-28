require "test_helper"

class BillingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as @user # Use shared helper
    @client = clients(:one)
    @operation = operations(:one) # Billings can be associated with an operation
    @billing = billings(:one)
    # Ensure the fixture billing belongs to the fixture client and optionally operation
    @billing.update(client: @client, operation: @operation)
  end

  test "should get index" do
    get billings_url
    assert_response :success
  end

  test "should get new" do
    get new_billing_url
    assert_response :success
  end

  test "should create billing" do
    assert_difference("Billing.count") do
      # Use @client.id and optionally @operation.id
      post billings_url, params: { billing: { client_id: @client.id, operation_id: @operation.id, amount: @billing.amount, due_date: @billing.due_date, status: "Pending" } }
    end

    assert_redirected_to billing_url(Billing.last)
  end

  test "should create billing without operation" do
    assert_difference("Billing.count") do
      post billings_url, params: { billing: { client_id: @client.id, operation_id: nil, amount: 100.00, due_date: Date.today + 15.days, status: "Pending" } }
    end

    assert_redirected_to billing_url(Billing.last)
    assert_nil Billing.last.operation_id
  end

  test "should show billing" do
    get billing_url(@billing)
    assert_response :success
  end

  test "should get edit" do
    get edit_billing_url(@billing)
    assert_response :success
  end

  test "should update billing" do
    patch billing_url(@billing), params: { billing: { status: "Paid" } }
    assert_redirected_to billing_url(@billing)
    @billing.reload
    assert_equal "Paid", @billing.status
  end

  test "should destroy billing" do
    assert_difference("Billing.count", -1) do
      delete billing_url(@billing)
    end

    assert_redirected_to billings_url
  end

end
