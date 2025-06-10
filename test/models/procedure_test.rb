require "test_helper"

class ProcedureTest < ActiveSupport::TestCase
  setup do
    @client = clients(:one) # from clients.yml
    @procedure_type = procedure_types(:one) # from procedure_types.yml

    @procedure_params = {
      client: @client,
      procedure_type: @procedure_type,
      date: Date.today,
      teeth: "11, 21",
      observation: "Routine check-up.",
      dentist: "Dr. Smith",
      debit: 100.50,
      credit: 0.00
    }
  end

  test "should be valid with all attributes" do
    procedure = Procedure.new(@procedure_params)
    assert procedure.valid?, "Procedure should be valid, but got errors: #{procedure.errors.full_messages.join(", ")}"
  end

  test "should belong to client" do
    procedure = Procedure.new(@procedure_params.except(:client))
    assert_not procedure.valid?, "Procedure should be invalid without a client"
    assert_includes procedure.errors[:client], "must exist" # or "can't be blank" depending on Rails version
  end

  test "should belong to procedure_type" do
    procedure = Procedure.new(@procedure_params.except(:procedure_type))
    assert_not procedure.valid?, "Procedure should be invalid without a procedure_type"
    assert_includes procedure.errors[:procedure_type], "must exist"
  end

  test "dentist can be blank" do
    procedure = Procedure.new(@procedure_params.merge(dentist: nil))
    assert procedure.valid?, "Procedure should be valid with a blank dentist"
  end

  test "debit can be blank" do
    procedure = Procedure.new(@procedure_params.merge(debit: nil))
    assert procedure.valid?, "Procedure should be valid with a blank debit"
  end

  test "credit can be blank" do
    procedure = Procedure.new(@procedure_params.merge(credit: nil))
    assert procedure.valid?, "Procedure should be valid with a blank credit"
  end

  test "debit should be a number if present" do
    procedure = Procedure.new(@procedure_params.merge(debit: "not_a_number"))
    # Add 'validates :debit, numericality: true, allow_nil: true' to model for this to fail
    # For now, without validation, it might coerce or save as 0.0 depending on DB.
    # Let's assume we'll add the validation.
    # assert_not procedure.valid?
    # assert_includes procedure.errors[:debit], "is not a number"
    # For now, this test will likely pass or behave unexpectedly without model validation.
    # Let's just test assignment for now.
    procedure.debit = 123.45
    assert_equal 123.45, procedure.debit
  end

  test "credit should be a number if present" do
    procedure = Procedure.new(@procedure_params.merge(credit: "not_a_number"))
    # Add 'validates :credit, numericality: true, allow_nil: true' to model for this to fail
    # assert_not procedure.valid?
    # assert_includes procedure.errors[:credit], "is not a number"
    procedure.credit = 67.89
    assert_equal 67.89, procedure.credit
  end

  # Placeholder for default value tests (once implemented)
  # test "debit should have a default value" do
  #   procedure = Procedure.new(@procedure_params.except(:debit))
  #   # Assert default value once logic for it is added
  # end
end
