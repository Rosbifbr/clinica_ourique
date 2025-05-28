require "test_helper"

class ClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one) # Assuming you have a users fixture
    sign_in_as @user      # Use shared helper
    @client = clients(:one) # Assuming you have a clients fixture
  end

  test "should get index" do
    get clients_url
    assert_response :success
  end

  test "should get new" do
    get new_client_url
    assert_response :success
  end

  test "should create client" do
    assert_difference("Client.count") do
      post clients_url, params: { client: { name: "New Client", cpf: "12345678901", phone: "123456789", birthdate: "2000-01-01", address: "Test Address", postal_code: "12345", neighborhood: "Test Neighborhood" } }
    end

    assert_redirected_to client_url(Client.last)
  end

  test "should show client" do
    get client_url(@client)
    assert_response :success
  end

  test "should get edit" do
    get edit_client_url(@client)
    assert_response :success
  end

  test "should update client" do
    patch client_url(@client), params: { client: { name: "Updated Client Name" } }
    assert_redirected_to client_url(@client)
    @client.reload
    assert_equal "Updated Client Name", @client.name
  end

  test "should destroy client" do
    assert_difference("Client.count", -1) do
      delete client_url(@client)
    end

    assert_redirected_to clients_url
  end

end
