json.extract! client, :id, :name, :cpf, :phone, :birthdate, :address, :postal_code, :neighborhood, :created_at, :updated_at
json.url client_url(client, format: :json)
