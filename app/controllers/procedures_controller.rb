class ProceduresController < ApplicationController
  before_action :set_client, only: [:new, :create]
    before_action :set_procedure, only: [:show, :edit, :update, :destroy]

  # GET /procedures/1 or /procedures/1.json
  def show
  end

  # GET /procedures/new
  def new
    @procedure = @client.procedures.build
  end

  # GET /procedures/1/edit
  def edit
  end

  # POST /procedures or /procedures.json
  def create
    @procedure = @client.procedures.build(procedure_params.except(:client_id))
    if @procedure.save
      redirect_to client_path(@client), notice: 'Procedure was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /procedures/1 or /procedures/1.json
  def update
    respond_to do |format|
      if @procedure.update(procedure_params)
        format.html { redirect_to client_path(@procedure.client), notice: "Procedure was successfully updated." }
        format.json { render :show, status: :ok, location: @procedure }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @procedure.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /procedures/1 or /procedures/1.json
  def destroy
    client = @procedure.client
    if @procedure.destroy
      respond_to do |format|
        format.html { redirect_to client_path(@procedure.client), status: :see_other, notice: "Procedure was successfully destroyed." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to client_path(@procedure.client), alert: "Failed to delete procedure." }
        format.json { render json: { error: "Failed to delete procedure" }, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_client
    if params[:client_id].present?
      @client = Client.find(params[:client_id])
    else
      redirect_to clients_path, alert: 'Client ID missing in request.'
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to clients_path, alert: 'Client not found.'
  end

  def set_procedure
    @procedure = Procedure.find(params[:id])
    @client = @procedure.client
  end

  def procedure_params
    params.require(:procedure).permit(:procedure_type_id, :observation, :date, :teeth, :client_id)
  end
end
