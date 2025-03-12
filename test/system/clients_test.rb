require "application_system_test_case"

class ClientsTest < ApplicationSystemTestCase
  setup do
    @client = clients(:one)
  end

  test "visiting the index" do
    visit clients_url
    assert_selector "h1", text: "Clients"
  end

  test "should create client" do
    visit clients_url
    click_on "New client"

    fill_in "Address", with: @client.address
    fill_in "Birthdate", with: @client.birthdate
    fill_in "Cpf", with: @client.cpf
    fill_in "Name", with: @client.name
    fill_in "Neighborhood", with: @client.neighborhood
    fill_in "Phone", with: @client.phone
    fill_in "Postal code", with: @client.postal_code
    click_on "Create Client"

    assert_text "Client was successfully created"
    click_on "Back"
  end

  test "should update Client" do
    visit client_url(@client)
    click_on "Edit this client", match: :first

    fill_in "Address", with: @client.address
    fill_in "Birthdate", with: @client.birthdate
    fill_in "Cpf", with: @client.cpf
    fill_in "Name", with: @client.name
    fill_in "Neighborhood", with: @client.neighborhood
    fill_in "Phone", with: @client.phone
    fill_in "Postal code", with: @client.postal_code
    click_on "Update Client"

    assert_text "Client was successfully updated"
    click_on "Back"
  end

  test "should destroy Client" do
    visit client_url(@client)
    click_on "Destroy this client", match: :first

    assert_text "Client was successfully destroyed"
  end
end
