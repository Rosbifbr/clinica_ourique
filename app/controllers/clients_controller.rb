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
      respond_to do |format|
        if @client.update(client_params)
          format.html { redirect_to @client, notice: "Client was successfully updated." }
          format.json { render :show, status: :ok, location: @client }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @client.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /clients/1 or /clients/1.json
    def destroy
      @client = Client.find(params[:id])
      @client.destroy
      redirect_to clients_path, notice: 'Client was successfully deleted.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_client
        @client = Client.find(params[:id])
      end

      def procedure_params
        params.require(:procedure).permit(:name, :date, :description)
      end

      # Only allow a list of trusted parameters through.
      def client_params
        params.require(:client).permit(:name, :cpf, :phone, :birthdate, :address, :postal_code, :neighborhood)
      end
  end
