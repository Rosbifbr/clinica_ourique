class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy, :destroy_image]

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
        flash.now[:alert] = 'There were errors creating the client.'
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clients/1 or /clients/1.json
  def update
    # Extract strong parameters for mass assignment first, excluding dental_map_json
    # as it's handled manually. client_params currently permits :dental_map (for direct file upload).
    safe_client_params = client_params

    # Handle dental_map_json from the original params[:client]
    if params.dig(:client, :dental_map_json).present?
      dental_map_json_data = params[:client][:dental_map_json] # Read original param

      if dental_map_json_data == "null"
        @client.dental_map.purge if @client.dental_map.attached?
      elsif dental_map_json_data.present? # Ensure it's not just "" (empty string)
        filename = "dental_map_#{Time.now.to_i}.json"
        temp_file = Tempfile.new(filename)
        begin
          temp_file.write(dental_map_json_data)
          temp_file.rewind

          @client.dental_map.purge if @client.dental_map.attached?
          @client.dental_map.attach(io: temp_file, filename: filename, content_type: "application/json")
        ensure
          temp_file.close
          temp_file.unlink # Delete the temp file
        end
      end
      # Remove :dental_map from safe_client_params if dental_map_json was processed,
      # to prevent @client.update from trying to process a direct :dental_map file upload
      # if one was somehow also sent (though current form doesn't do this).
      safe_client_params = safe_client_params.except(:dental_map)
    end

    # The :images attribute is handled by ActiveStorage's direct assignment if permitted in client_params.
    # No need for manual iteration if `images: []` is in permit and form sends it correctly.
    # The existing `if params[:client][:images]` block for manual iteration is thus redundant
    # if `images: []` is in `client_params`. Let's rely on `client_params`.

    respond_to do |format|
      if @client.update(safe_client_params)
        format.html { redirect_to client_url(@client), notice: "Client was successfully updated." }
        format.json { render :show, status: :ok, location: @client }
      else
        flash.now[:alert] = 'There were errors updating the client.'
        format.html { render :edit, status: :unprocessable_entity }
        json_errors = @client.errors.as_json
        if dental_map_json_data.present? && !@client.dental_map.attached? && dental_map_json_data != "null"
          json_errors[:dental_map] = ["could not be processed or attached from JSON data."]
        end
        format.json { render json: json_errors, status: :unprocessable_entity }
      end
    end
  end

  # reset_odontogram action removed

  # DELETE /clients/1 or /clients/1.json
  def destroy
    # Old manual deletion of odontogram_path removed.
    # ActiveStorage attachments (like dental_map and images) should have dependent: :purge or be manually purged if needed.
    # has_one_attached :dental_map (by default, no dependent purge)
    # has_many_attached :images, dependent: :destroy (will purge)
    # So, dental_map needs explicit purge if we want it gone when client is destroyed.
    @client.dental_map.purge if @client.dental_map.attached?
    # images will be purged due to dependent: :destroy in the model.

    if @client.destroy
      redirect_to clients_path, notice: "Client was successfully deleted."
    else
      redirect_to clients_path, alert: "Failed to delete client."
    end
  end

  # DELETE /clients/1/images/:image_id
  def destroy_image
    image = @client.images.find(params[:image_id])
    image.purge

    respond_to do |format|
      format.html { redirect_to @client, notice: 'Image was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_client
    @client = Client.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def client_params
    params.require(:client).permit(:name, :cpf, :phone, :phone2, :birthdate, :address, :postal_code, :neighborhood, :observation, :dental_map, images: [])
  end
end
