class BillingsController < ApplicationController
  before_action :set_billing, only: %i[ show edit update destroy ]

  # GET /billings or /billings.json
  def index
    @billings = Billing.all
  end

  # GET /billings/1 or /billings/1.json
  def show
  end

  # GET /billings/new
  def new
    @billing = Billing.new
  end

  # GET /billings/1/edit
  def edit
  end

  # POST /billings or /billings.json
  def create
    @billing = Billing.new(billing_params)

    respond_to do |format|
      if @billing.save
        format.html { redirect_to @billing, notice: "Billing was successfully created." }
        format.json { render :show, status: :created, location: @billing }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @billing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /billings/1 or /billings/1.json
  def update
    respond_to do |format|
      if @billing.update(billing_params)
        format.html { redirect_to @billing, notice: "Billing was successfully updated." }
        format.json { render :show, status: :ok, location: @billing }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @billing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /billings/1 or /billings/1.json
  def destroy
    @billing.destroy!

    respond_to do |format|
      format.html { redirect_to billings_path, status: :see_other, notice: "Billing was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_billing
      @billing = Billing.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def billing_params
      params.expect(billing: [ :client_id, :operation_id, :amount, :due_date, :status ])
    end
end
