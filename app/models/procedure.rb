class Procedure < ApplicationRecord
  belongs_to :client
  belongs_to :procedure_type
end
