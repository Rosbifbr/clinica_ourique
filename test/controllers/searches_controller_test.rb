require "test_helper"

class SearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one) # For authentication, if search page requires login
    sign_in_as(@user)   # Assumes search is behind authentication

    # Ensure some searchable data exists via fixtures
    # clients(:one) -> Name: "Fixture Client One", CPF: "000.000.000-00"
    # procedures(:one) -> Observation: "Fixture procedure one", Teeth: "11, 12", Dentist: "Dr. Fixture"
    #                   -> client: clients(:one), procedure_type: procedure_types(:one) ["Cleaning"]
  end

  test "should get show (search page)" do
    get "/searches/show" # Using direct path
    assert_response :success
  end

  test "should get show with empty search term" do
    get "/searches/show", params: { q: "" }
    assert_response :success
    assert_equal "", assigns(:search_term)
    assert_empty assigns(:client_results)
    assert_empty assigns(:procedure_results)
  end

  test "should find client by name" do
    client_name = clients(:one).name # "Fixture Client One"
    get "/searches/show", params: { q: client_name }
    assert_response :success
    assert_equal client_name, assigns(:search_term)
    assert_not_empty assigns(:client_results), "Should find at least one client"
    assert_includes assigns(:client_results).map(&:name), client_name
  end

  test "should find client by partial name (case-insensitive)" do
    get "/searches/show", params: { q: "fixture client" } # Partial and lowercase
    assert_response :success
    assert_not_empty assigns(:client_results), "Should find clients by partial lowercase name"
    assert assigns(:client_results).any? { |c| c.name.downcase.include?("fixture client one") }
  end

  test "should find client by cpf" do
    client_cpf = clients(:one).cpf # "000.000.000-00"
    get "/searches/show", params: { q: client_cpf }
    assert_response :success
    assert_not_empty assigns(:client_results)
    assert_includes assigns(:client_results).map(&:cpf), client_cpf
  end

  test "should find procedure by observation" do
    proc_observation = procedures(:one).observation # "Fixture procedure one"
    get "/searches/show", params: { q: proc_observation }
    assert_response :success
    assert_not_empty assigns(:procedure_results), "Should find at least one procedure by observation"
    assert assigns(:procedure_results).any? { |p| p.observation == proc_observation }
  end

  test "should find procedure by dentist" do
    proc_dentist = procedures(:one).dentist # "Dr. Fixture"
    get "/searches/show", params: { q: proc_dentist }
    assert_response :success
    assert_not_empty assigns(:procedure_results)
    assert assigns(:procedure_results).any? { |p| p.dentist == proc_dentist }
  end

  test "should find procedure by client name associated with it" do
    client_name_for_proc = clients(:one).name # Client associated with procedures(:one)
    get "/searches/show", params: { q: client_name_for_proc }
    assert_response :success
    # This search term will also match clients, so check both or make term more specific if needed
    assert_not_empty assigns(:procedure_results), "Should find procedures by associated client name"
    assert assigns(:procedure_results).any? { |p| p.client.name == client_name_for_proc }
  end

  test "should find procedure by procedure type name associated with it" do
    proc_type_name = procedure_types(:one).name # e.g., "Cleaning"
    get "/searches/show", params: { q: proc_type_name }
    assert_response :success
    assert_not_empty assigns(:procedure_results), "Should find procedures by associated type name"
    assert assigns(:procedure_results).any? { |p| p.procedure_type.name == proc_type_name }
  end

  test "should return no results for a very specific non-matching term" do
    get "/searches/show", params: { q: "xyz123qwerty_no_match_possible_!@#" }
    assert_response :success
    assert_empty assigns(:client_results)
    assert_empty assigns(:procedure_results)
  end
end
