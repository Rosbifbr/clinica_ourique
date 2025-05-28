require "test_helper"

class BillingTest < ActiveSupport::TestCase
  test "should be valid and save with a client and no operation" do
    client = Client.create(name: "Test Client For Billing", cpf: "11122233344") # Unique CPF
    assert client.persisted?, "Client should be persisted. Errors: #{client.errors.full_messages.join(", ")}"

    billing = Billing.new(client: client, amount: 100, due_date: Date.today, status: "Pending")
    assert billing.valid?, "Billing should be valid. Errors: #{billing.errors.full_messages.join(", ")}"
    assert billing.save, "Billing should save successfully. Errors: #{billing.errors.full_messages.join(", ")}"
  end

  test "should be valid and save with a client and an operation" do
    client = Client.create(name: "Test Client For Billing Op", cpf: "55566677788") # Unique CPF
    assert client.persisted?, "Client should be persisted. Errors: #{client.errors.full_messages.join(", ")}"

    operation = client.operations.create(description: "Test Op For Billing", date: Date.today, cost: 50, status: "Done")
    assert operation.persisted?, "Operation should be persisted. Errors: #{operation.errors.full_messages.join(", ")}"
    
    billing = Billing.new(client: client, operation: operation, amount: 50, due_date: Date.today, status: "Paid")
    assert billing.valid?, "Billing should be valid. Errors: #{billing.errors.full_messages.join(", ")}"
    assert billing.save, "Billing should save successfully. Errors: #{billing.errors.full_messages.join(", ")}"
  end

  test "should have amount" do
    client = Client.create(name: "Test Client Amount", cpf: "12312312311")
    billing = Billing.new(client: client, due_date: Date.today, status: "Pending")
    assert_not billing.valid?, "Billing should be invalid without an amount"
    assert billing.errors[:amount].any?, "Should have an error on amount"
  end

  test "should have due_date" do
    client = Client.create(name: "Test Client DueDate", cpf: "32132132122")
    billing = Billing.new(client: client, amount: 100, status: "Pending")
    assert_not billing.valid?, "Billing should be invalid without a due_date"
    assert billing.errors[:due_date].any?, "Should have an error on due_date"
  end

  test "should have status" do
    client = Client.create(name: "Test Client Status", cpf: "45645645633")
    billing = Billing.new(client: client, amount: 100, due_date: Date.today)
    assert_not billing.valid?, "Billing should be invalid without a status"
    assert billing.errors[:status].any?, "Should have an error on status"
  end

  test "should belong to client" do
    billing = Billing.new(amount: 100, due_date: Date.today, status: "Pending")
    assert_not billing.valid?, "Billing should be invalid without a client"
    assert billing.errors[:client].any?, "Should have an error on client for belongs_to association"
  end
end
