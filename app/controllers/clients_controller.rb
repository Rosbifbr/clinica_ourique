class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  # GET /clients or /clients.json
  def index
    if params[:search].present?
      @clients = Client.where("name LIKE ? OR cpf LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    else
      @clients = Client.all
    end
  end

  # GET /clients/1 or /clients/1.json
  def show
    @procedures_for_client = @client.procedures
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients or /clients.json
  def create
    @client = Client.new(client_params)
    respond_to do |format|
      if @client.save
        format.html { redirect_to @client, notice: "Client was successfully created." }
        format.json { render :show, status: :created, location: @client }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clients/1 or /clients/1.json
  def update
    if params[:client]&.dig(:odontogram_action) == "reset_to_default"
      # Reset to default by clearing the path
      @client.odontogram_path = nil
      @client.save

      # Remove the temporary parameters
      params[:client].delete(:odontogram_action)
      params[:client].delete(:odontogram_image)

      redirect_to client_url(@client), notice: "Odontogram reset to default."
      return
    elsif params[:client][:odontogram_image].present?
      # Handle custom image upload as before
      uploaded_io = params[:client][:odontogram_image]
      filename = "odontogram_#{@client.id}_#{Time.now.to_i}#{File.extname(uploaded_io.original_filename).downcase}"

      File.open(Rails.root.join('public', 'uploads', 'odontograms', filename), 'wb') do |file|
        file.write(uploaded_io.read)
      end

      params[:client][:odontogram_path] = filename
    end

    params[:client].delete(:odontogram_action)
    params[:client].delete(:odontogram_image)

    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to client_url(@client), notice: "Client was successfully updated." }
        format.json { render :show, status: :ok, location: @client }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def reset_odontogram
    @client.odontogram_path = nil

    if @client.save
      redirect_to client_path(@client), notice: "Odontogram has been reset to default."
    else
      redirect_to client_path(@client), alert: "Failed to reset odontogram."
    end
  end

  # DELETE /clients/1 or /clients/1.json
  def destroy
    if @client.odontogram_path.present?
      odontogram_file_path = Rails.root.join('public', 'uploads', 'odontograms', @client.odontogram_path)
      File.delete(odontogram_file_path) if File.exist?(odontogram_file_path)
    end

    if @client.destroy
      redirect_to clients_path, notice: "Client was successfully deleted."
    else
      redirect_to clients_path, alert: "Failed to delete client."
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_client
    @client = Client.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def client_params
    params.require(:client).permit(:name, :cpf, :phone, :birthdate, :address, :postal_code, :neighborhood, :observation, :odontogram_path)
  end
end
