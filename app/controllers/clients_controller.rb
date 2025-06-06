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
    # Old odontogram_action and odontogram_image logic removed.
    # ActiveStorage handles dental_map attachment directly via client_params.

    # Keep existing logic for attaching multiple images if present
    if params[:client][:images]
      params[:client][:images].each do |image|
        @client.images.attach(image)
      end
    end

    respond_to do |format|
      if @client.update(client_params)
        # If dental_map is being cleared, purge it.
        # This assumes a checkbox or similar `params[:client][:remove_dental_map] == '1'` could be used in the form.
        # Or, if dental_map is simply not provided in client_params for an update, it remains unchanged.
        # If params[:client][:dental_map] is nil and there was an existing map, it will NOT be detached by default.
        # Explicit purge is needed if a "remove" checkbox is implemented.
        # For now, let's assume client_params handles setting/replacing dental_map.
        # If `dental_map` is passed as `nil` explicitly in params and the model is updated,
        # `has_one_attached` might detach it, but this behavior can be subtle.
        # A common pattern is a separate "remove_dental_map" checkbox.
        # params[:client][:dental_map].nil? might not be enough if the field wasn't in the form.
        # If :dental_map is not in client_params at all, it won't be touched.
        # If :dental_map is in client_params and is nil (e.g. from an empty file field), it will try to attach nil,
        # which effectively can detach an existing one for `has_one_attached`.

        format.html { redirect_to client_url(@client), notice: "Client was successfully updated." }
        format.json { render :show, status: :ok, location: @client }
      else
        flash.now[:alert] = 'There were errors updating the client.'
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @client.errors, status: :unprocessable_entity }
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
    params.require(:client).permit(:name, :cpf, :phone, :birthdate, :address, :postal_code, :neighborhood, :observation, :dental_map, images: [])
  end
end
