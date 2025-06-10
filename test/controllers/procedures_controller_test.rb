require "test_helper"

class ProceduresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one) # Assuming users(:one) fixture exists
    sign_in_as(@user)   # Sign in the user

    @client = clients(:one) # Assuming clients(:one) fixture exists
    @procedure_type = procedure_types(:one) # Assuming procedure_types(:one) exists

    # Use an existing procedure from fixtures for show, edit, update, destroy
    # Ensure procedures.yml has a :one fixture associated with @client and @procedure_type
    # If procedures(:one) is not guaranteed to be linked to clients(:one), adjust this.
    # For simplicity, let's assume procedures(:one) is fine or create a new one.
    @procedure = procedures(:one)
    # Ensure @procedure belongs to @client for path helpers to work correctly if they expect it.
    # Or, fetch a procedure that belongs to @client:
    # @procedure = @client.procedures.create!(procedure_type: @procedure_type, date: Date.today, dentist: "Test Dentist")
    # For now, using procedures(:one) and hoping it's generally usable or will be fixed by fixture setup.
    # A better setup for @procedure for actions other than new/create:
    @procedure_for_actions = @client.procedures.create!(
        procedure_type: @procedure_type,
        date: Date.today,
        teeth: "11",
        observation: "Test obs",
        dentist: "Dr. Action",
        debit: 10, credit: 0
    )


    @valid_procedure_params = {
      procedure_type_id: @procedure_type.id,
      date: Date.tomorrow, # Test with a specific date
      teeth: "21-23",
      observation: "Annual checkup and cleaning.",
      dentist: "Dr. Eva Core",
      debit: 150.75,
      credit: 20.00
      # client_id is handled by nesting or set_client
    }
  end

  test "should get new procedure for client" do
    get new_client_procedure_url(@client)
    assert_response :success
    procedure_assigned = @controller.instance_variable_get(:@procedure)
    assert_not_nil procedure_assigned
    assert_equal Date.today, procedure_assigned.date, "Default date should be today"
  end

  test "should create procedure for client" do
    assert_difference("@client.procedures.count") do
      post client_procedures_url(@client), params: { procedure: @valid_procedure_params }
    end

    new_procedure = @client.procedures.last
    assert_redirected_to client_path(@client) # Redirects to client show page
    assert_equal "Procedure was successfully created.", flash[:notice]
    assert_equal @valid_procedure_params[:dentist], new_procedure.dentist
    assert_equal @valid_procedure_params[:debit], new_procedure.debit
    assert_equal @valid_procedure_params[:credit], new_procedure.credit
  end

  test "should show procedure" do
    # Note: Procedures are nested under clients for new/create.
    # Show, edit, update, destroy typically use /procedures/:id
    # The routes file shows: resources :procedures, except: [:index]
    # And `client do resources :procedures end`
    # So, procedure_url(@procedure_for_actions) should work.
    get procedure_url(@procedure_for_actions)
    assert_response :success
  end

  test "should get edit procedure" do
    get edit_procedure_url(@procedure_for_actions)
    assert_response :success
  end

  test "should update procedure" do
    patch procedure_url(@procedure_for_actions), params: { procedure: { observation: "Updated observation", dentist: "Dr. New" } }
    assert_redirected_to client_path(@procedure_for_actions.client) # Redirects to client show page
    @procedure_for_actions.reload
    assert_equal "Updated observation", @procedure_for_actions.observation
    assert_equal "Dr. New", @procedure_for_actions.dentist
  end

  test "should destroy procedure" do
    # Create a procedure specifically for this test to avoid issues with other tests
    procedure_to_destroy = @client.procedures.create!(@valid_procedure_params.except(:date).merge(date: Date.yesterday))

    assert_difference("@client.procedures.count", -1) do
      delete procedure_url(procedure_to_destroy)
    end
    assert_redirected_to client_path(@client)
  end

  # Test for invalid parameters (e.g., missing procedure_type_id)
  test "should not create procedure without procedure_type" do
    assert_no_difference("@client.procedures.count") do
      post client_procedures_url(@client), params: { procedure: @valid_procedure_params.except(:procedure_type_id) }
    end
    # Assuming it re-renders :new on failure with status :unprocessable_entity
    assert_response :success # The controller currently just renders :new without a status
    # Check if @procedure.errors is populated, or if a specific error message is shown.
    # The controller currently has `render :new` which is a 200 OK.
    # For better RESTfulness, it should be `render :new, status: :unprocessable_entity`
    # For now, test based on current behavior.
  end
end
