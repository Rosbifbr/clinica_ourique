json.extract! billing, :id, :client_id, :operation_id, :amount, :due_date, :status, :created_at, :updated_at
json.url billing_url(billing, format: :json)
