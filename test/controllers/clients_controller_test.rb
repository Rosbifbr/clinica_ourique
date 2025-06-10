require "test_helper"

class ClientsControllerTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess::FixtureFile # For fixture_file_upload

  setup do
    @user = users(:one) # From users.yml fixture
    sign_in_as(@user) # Helper from test_helper.rb

    # Assuming clients.yml fixture exists, e.g. :one_client
    # If not, create one or use attributes to create a client here.
    # Let's ensure clients.yml has a basic client.
    # The previous model test subtask created test/fixtures/clients.yml
    @client = clients(:one) # from clients.yml

    @client_params = {
      name: "New Client Name",
      cpf: "111.222.333-44",
      phone: "(22) 12345-6789",
      birthdate: "1985-05-15",
      address: "456 New Ave",
      postal_code: "54321-876",
      neighborhood: "Uptown",
      observation: "Client observations",
      phone2: "(33) 91111-2222"
    }
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
      post clients_url, params: { client: @client_params }
    end
    assert_redirected_to client_url(Client.last)
    assert_equal "Client was successfully created.", flash[:notice]
  end

  test "should create client with dental_map" do
    dental_map_image = fixture_file_upload("sample_image.png", "image/png") # Corrected path
    assert_difference("Client.count") do
      post clients_url, params: { client: @client_params.merge(dental_map: dental_map_image) }
    end
    assert_redirected_to client_url(Client.last)
    assert Client.last.dental_map.attached?, "Dental map should be attached"
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

  test "should update client and attach new dental_map" do
    new_dental_map = fixture_file_upload("sample_image.png", "image/png") # Corrected path
    patch client_url(@client), params: { client: { dental_map: new_dental_map } }
    assert_redirected_to client_url(@client)
    @client.reload
    assert @client.dental_map.attached?, "New dental map should be attached"
  end

  test "should destroy client" do
    # Attach a dental_map to test its purging
    dental_map_image = fixture_file_upload("sample_image.png", "image/png") # Corrected path
    @client.dental_map.attach(dental_map_image)
    assert @client.dental_map.attached?

    assert_difference("Client.count", -1) do
      delete client_url(@client)
    end
    assert_redirected_to clients_url # Or wherever your destroy action redirects

    # Verify that the dental_map attachment is purged
    # ActiveStorage attachments are deleted from DB via dependent: :destroy on the attachment record itself,
    # and the actual file is purged via a background job (ActiveStorage::PurgeJob).
    # For testing, if jobs run inline, it's purged immediately. If not, it's enqueued.
    # A simple check is that the blob record is gone.
    assert_not Client.exists?(@client.id) # Client record is gone
    # Check if the attachment record is gone (this is implicit if client is gone and has dependent destroy)
    # To directly check if blob is purged/unattached:
    # assert_raises(ActiveRecord::RecordNotFound) { @client.dental_map.blob } # This won't work as @client is destroyed
    # A better way is to check if the blob associated with that client is still around.
    # This test is simplified; in a real scenario, you might need to check ActiveStorage::Blob.count
    # or ensure no ActiveStorage::Attachment record points to the destroyed client.
    # The controller now has `@client.dental_map.purge if @client.dental_map.attached?` which is synchronous.
    # So, the attachment should be gone immediately.
    # Let's refine this test slightly.
  end

  test "destroying client purges dental_map" do
    dental_map_image = fixture_file_upload("sample_image.png", "image/png") # Corrected path
    client_to_destroy = Client.create!(@client_params) # Create a fresh client for this test
    client_to_destroy.dental_map.attach(dental_map_image)
    assert client_to_destroy.dental_map.attached?

    # Store blob_id before destroying
    blob_id = client_to_destroy.dental_map.blob.id

    assert_difference("Client.count", -1) do
      delete client_url(client_to_destroy)
    end

    assert_redirected_to clients_url
    assert_not ActiveStorage::Blob.exists?(blob_id), "ActiveStorage Blob for dental_map should have been purged"
  end

  test "should create client with phone2" do
    assert_difference("Client.count") do
      post clients_url, params: { client: @client_params } # @client_params now includes phone2
    end
    assert_redirected_to client_url(Client.last)
    assert_equal @client_params[:phone2], Client.last.phone2
  end

  test "should create client without phone2" do
    assert_difference("Client.count") do
      post clients_url, params: { client: @client_params.except(:phone2) }
    end
    assert_redirected_to client_url(Client.last)
    assert_nil Client.last.phone2
  end

  test "should update client with phone2" do
    client_to_update = clients(:one) # from fixtures
    patch client_url(client_to_update), params: { client: { phone2: "newphone2value" } }
    assert_redirected_to client_url(client_to_update)
    client_to_update.reload
    assert_equal "newphone2value", client_to_update.phone2
  end

  test "should create client without address and postal_code" do
    minimal_params = {
      name: "Minimal Client",
      cpf: "98765432100",
      phone: "0987654321"
      # No address, postal_code, phone2 etc.
    }
    assert_difference("Client.count") do
      post clients_url, params: { client: minimal_params }
    end
    assert_redirected_to client_url(Client.last)
    new_client = Client.last
    assert_nil new_client.address
    assert_nil new_client.postal_code
    assert_nil new_client.phone2 # Also checking phone2 is nil by default from these params
  end

  test "should update client and save dental_map_json as attachment" do
    client_to_update = clients(:one) # from fixtures
    # Ensure dental_map is initially not attached or purge it to ensure a clean state for this specific test.
    client_to_update.dental_map.purge if client_to_update.dental_map.attached?
    assert_not client_to_update.dental_map.attached?, "Dental map should not be initially attached for this test client"

    valid_fabric_json = '{"version":"5.3.0","objects":[{"type":"rect","left":50,"top":50,"width":20,"height":20,"fill":"red"}]}'
    patch client_url(client_to_update), params: { client: { dental_map_json: valid_fabric_json } }

    assert_redirected_to client_url(client_to_update)
    client_to_update.reload
    assert client_to_update.dental_map.attached?, "Dental map should be attached after update with JSON data"

    # Verify content of the attached file
    attached_json_content = client_to_update.dental_map.blob.download
    assert_equal valid_fabric_json, attached_json_content, "Attached dental map content should match submitted JSON"
    assert_equal "application/json", client_to_update.dental_map.blob.content_type
    assert client_to_update.dental_map.blob.filename.to_s.starts_with?("dental_map_"), "Filename should start with dental_map_"
    assert client_to_update.dental_map.blob.filename.to_s.ends_with?(".json"), "Filename should end with .json"
  end

  test "should purge dental_map if dental_map_json is 'null'" do
    client_to_update = clients(:one)
    # Attach a dummy file first to ensure it gets purged
    dummy_content = '{ "initial": "data" }'
    client_to_update.dental_map.attach(io: StringIO.new(dummy_content), filename: "dummy.json", content_type: "application/json")
    assert client_to_update.dental_map.attached?, "Dental map should be attached before purging"

    patch client_url(client_to_update), params: { client: { dental_map_json: "null" } }

    assert_redirected_to client_url(client_to_update)
    client_to_update.reload
    assert_not client_to_update.dental_map.attached?, "Dental map should be purged if 'null' is submitted"
  end

  test "update with empty dental_map_json string should not purge or attach" do
    client_to_update = clients(:one)
    # Optionally attach something first
    client_to_update.dental_map.attach(io: StringIO.new('{"old":"data"}'), filename: "old.json", content_type: "application/json")
    assert client_to_update.dental_map.attached?

    original_blob_id = client_to_update.dental_map.blob.id

    patch client_url(client_to_update), params: { client: { dental_map_json: "" } } # Empty string

    assert_redirected_to client_url(client_to_update)
    client_to_update.reload
    assert client_to_update.dental_map.attached?, "Dental map should still be attached if empty string submitted"
    assert_equal original_blob_id, client_to_update.dental_map.blob.id, "Dental map blob should not have changed"
  end

  test "update with no dental_map_json param should not affect existing dental_map" do
    client_to_update = clients(:one)
    client_to_update.dental_map.attach(io: StringIO.new('{"existing":"data"}'), filename: "existing.json", content_type: "application/json")
    assert client_to_update.dental_map.attached?
    original_blob_id = client_to_update.dental_map.blob.id

    patch client_url(client_to_update), params: { client: { name: "Just updating name" } } # No dental_map_json

    assert_redirected_to client_url(client_to_update)
    client_to_update.reload
    assert client_to_update.dental_map.attached?, "Dental map should still be attached if param not sent"
    assert_equal original_blob_id, client_to_update.dental_map.blob.id, "Dental map blob should not have changed"
  end
end
