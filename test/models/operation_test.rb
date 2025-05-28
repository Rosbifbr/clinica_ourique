require "test_helper"

class OperationTest < ActiveSupport::TestCase
  setup do
    @client = clients(:one) # From fixtures
  end

  test "should have description" do
    operation = Operation.new(client: @client, date: Date.today, cost: 100, status: "Scheduled")
    assert_not operation.valid?, "Operation should be invalid without a description"
    assert operation.errors[:description].any?, "Should have an error on description"
  end

  test "should have date" do
    operation = Operation.new(client: @client, description: "Test Operation", cost: 100, status: "Scheduled")
    assert_not operation.valid?, "Operation should be invalid without a date"
    assert operation.errors[:date].any?, "Should have an error on date"
  end

  test "should have cost" do
    operation = Operation.new(client: @client, description: "Test Operation", date: Date.today, status: "Scheduled")
    assert_not operation.valid?, "Operation should be invalid without a cost"
    assert operation.errors[:cost].any?, "Should have an error on cost"
  end

  test "should have status" do
    operation = Operation.new(client: @client, description: "Test Operation", date: Date.today, cost: 100)
    assert_not operation.valid?, "Operation should be invalid without a status"
    assert operation.errors[:status].any?, "Should have an error on status"
  end

  test "should belong to client" do
    operation = Operation.new(description: "Test Operation", date: Date.today, cost: 100, status: "Scheduled")
    assert_not operation.valid?, "Operation should be invalid without a client"
    assert operation.errors[:client].any?, "Should have an error on client for belongs_to association"

    operation.client = @client
    assert operation.valid?, "Operation should be valid with a client. Errors: #{operation.errors.full_messages.join(", ")}"
    assert_equal @client, operation.client
  end

  test "should have many billings" do
    operation = operations(:one) # From fixtures
    assert_difference("operation.billings.count") do
      operation.billings.create!(client: operation.client, amount: 50, due_date: Date.today + 10.days, status: "Pending")
    end
  end
end
