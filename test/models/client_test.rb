require "test_helper"

class ClientTest < ActiveSupport::TestCase
  test "should have name" do
    client = Client.new(cpf: "12345678900")
    assert_not client.valid?, "Client should be invalid without a name"
    assert client.errors[:name].any?, "Should have an error on name"
  end

  test "should have cpf" do
    client = Client.new(name: "Test Client")
    assert_not client.valid?, "Client should be invalid without a cpf"
    assert client.errors[:cpf].any?, "Should have an error on cpf"
  end

  test "cpf should be unique" do
    existing_client = clients(:one) # From fixtures
    client = Client.new(name: "Another Client", cpf: existing_client.cpf)
    assert_not client.valid?, "Client should be invalid with a duplicate cpf"
    assert client.errors[:cpf].any?, "Should have an error on cpf for uniqueness"
  end

  test "should have many operations" do
    client = clients(:one)
    assert_difference("client.operations.count") do
      client.operations.create!(description: "Test Operation", date: Date.today, cost: 100, status: "Scheduled", client_id: client.id)
    end
  end

  test "should have many billings" do
    client = clients(:one)
    assert_difference("client.billings.count") do
      client.billings.create!(amount: 50, due_date: Date.today + 10.days, status: "Pending", client_id: client.id)
    end
  end
end
