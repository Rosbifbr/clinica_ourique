require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one) # Assumes users(:one) fixture exists for authentication
    sign_in_as(@user)

    # Fixture data setup:
    # clients: :one, :two
    # procedure_types: :one (e.g., Cleaning), :two (e.g., Extraction)
    # procedures: Link some to client one, some to client two, with different dates and types.

    # Example:
    # procedures(:proc1_client1_type1_today) -> client: clients(:one), procedure_type: procedure_types(:one), date: Date.today, debit: 100
    # procedures(:proc2_client1_type2_yesterday) -> client: clients(:one), procedure_type: procedure_types(:two), date: Date.yesterday, debit: 200
    # procedures(:proc3_client2_type1_last_month) -> client: clients(:two), procedure_type: procedure_types(:one), date: Date.today.last_month, debit: 150

    # These fixtures (clients, procedure_types, procedures) should have been created/updated in previous steps.
    # We primarily need procedures with dates, debits, credits, and types.
    # And clients with birthdates.
  end

  # --- Financial Report Tests ---
  test "should get financial report" do
    get "/reports/financial" # Using direct path due to potential named route issues
    assert_response :success
    assert_not_nil assigns(:total_debit), "Should assign @total_debit"
    assert_not_nil assigns(:total_credit), "Should assign @total_credit"
    assert_not_nil assigns(:net_balance), "Should assign @net_balance"
    assert_not_nil assigns(:financial_summary_by_client), "Should assign @financial_summary_by_client"
  end

  test "financial report should filter by date range" do
    # Assuming procedures exist that would be filtered out by this range
    get "/reports/financial", params: { start_date: Date.today + 1.day, end_date: Date.today + 2.days }
    assert_response :success
    assert_equal 0, assigns(:total_debit), "Total debit should be 0 for future date range with no procedures"
    # For the summary by client, the result is an array of hashes. Check its emptiness.
    assert_empty assigns(:financial_summary_by_client), "Summary by client should be empty for this range"
  end

  test "financial report should filter by client" do
    client_one_id = clients(:one).id
    # Calculate expected debit for client one based on procedures.yml
    # procedures.yml has :one and :two belonging to clients(:one)
    expected_debit_client_one = procedures(:one).debit + procedures(:two).debit

    get "/reports/financial", params: { client_id: client_one_id }
    assert_response :success
    assert_equal expected_debit_client_one, assigns(:total_debit), "Total debit should match for client one"
    assert_equal 1, assigns(:financial_summary_by_client).count, "Summary should only contain client one"
    # The summary is an array of objects/hashes that respond to :client_name or ['client_name']
    assert_equal clients(:one).name, assigns(:financial_summary_by_client).first.client_name
  end

  # --- Birthdays Report Tests ---
  test "should get birthdays report" do
    get "/reports/birthdays"
    assert_response :success
    assert_not_nil assigns(:clients), "Should assign @clients for birthdays report"
  end

  test "birthdays report should filter by month" do
    # Client one: March 15. Client two: July 20. (from clients.yml)
    get "/reports/birthdays", params: { month: 3 } # March
    assert_response :success
    returned_clients = assigns(:clients)
    assert_equal 1, returned_clients.count, "Should find 1 client for month 3"
    assert_equal clients(:one).name, returned_clients.first.name
  end

  test "birthdays report should filter by date range (month-day)" do
    # Client one: March 15. Client two: July 20.
    # Range: March 1 to March 31
    # Use a year for Date.new that won't cause issues with Date.parse in controller if it uses a specific year.
    # Controller logic uses strftime('%m-%d'), so year of parameter doesn't matter for range logic.
    get "/reports/birthdays", params: { start_date: "2024-03-01", end_date: "2024-03-31" }
    assert_response :success
    returned_clients = assigns(:clients)
    assert_equal 1, returned_clients.count, "Should find 1 client for March date range"
    assert_equal clients(:one).name, returned_clients.first.name
  end


  # --- Procedures Report Tests ---
  test "should get procedures report" do
    get "/reports/procedures"
    assert_response :success
    assert_not_nil assigns(:procedures_summary), "Should assign @procedures_summary"
    assert_not_nil assigns(:filtered_procedures), "Should assign @filtered_procedures"
  end

  test "procedures report should filter by procedure type" do
    type_one_id = procedure_types(:one).id # e.g., Cleaning
    # Count how many procedures of type_one exist in fixtures
    # procedures :one and :three are type_one
    expected_count = 2

    get "/reports/procedures", params: { procedure_type_id: type_one_id }
    assert_response :success
    summary = assigns(:procedures_summary) # This is an array of [name, count] pairs

    type_one_summary = summary.find { |name, count_val| name == procedure_types(:one).name }
    assert_not_nil type_one_summary, "Summary for procedure type one should exist"
    assert_equal expected_count, type_one_summary[1], "Count for type one should match fixture data"

    assert_equal expected_count, assigns(:filtered_procedures).count
  end

  test "procedures report should filter by date range" do
    # procedures.yml: one (Date.today - 1), two (Date.today - 2), three (Date.today.last_month)

    # Test for a range covering only procedure :one
    get "/reports/procedures", params: { start_date: Date.today - 1.day, end_date: Date.today - 1.day }
    assert_response :success
    assert_equal 1, assigns(:filtered_procedures).count, "Should find 1 procedure for the specific date"
    assert_equal procedures(:one).id, assigns(:filtered_procedures).first.id
  end

end
