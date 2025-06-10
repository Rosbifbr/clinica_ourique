class SearchesController < ApplicationController
  def show
    @search_term = params[:q]
    @client_results = []
    @procedure_results = []

    if @search_term.present?
      search_term_like = "%#{@search_term.downcase}%" # Use downcase for case-insensitive

      @client_results = Client.where(
        "LOWER(name) LIKE :term OR " + # Changed ILIKE to LIKE
        "LOWER(cpf) LIKE :term OR " +
        "LOWER(phone) LIKE :term OR " +
        "LOWER(phone2) LIKE :term OR " +
        "LOWER(address) LIKE :term OR " +
        "LOWER(neighborhood) LIKE :term OR " +
        "LOWER(observation) LIKE :term",
        term: search_term_like
      ).limit(50)

      @procedure_results = Procedure.includes(:client, :procedure_type).where(
        "LOWER(procedures.observation) LIKE :term OR " + # Changed ILIKE to LIKE
        "LOWER(procedures.teeth) LIKE :term OR " +
        "LOWER(procedures.dentist) LIKE :term OR " +
        "LOWER(clients.name) LIKE :term OR " +
        "LOWER(procedure_types.name) LIKE :term",
        term: search_term_like
      ).references(:client, :procedure_type).limit(50)
    end
  end
end
