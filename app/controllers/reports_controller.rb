require 'ostruct'

class ReportsController < ApplicationController
  def financial
    @clients = Client.order(:name)

    base_query = Procedure.all # Removed .includes(:client)

    if params[:client_id].present?
      base_query = base_query.where(client_id: params[:client_id])
    end
    if params[:start_date].present?
      base_query = base_query.where("procedures.date >= ?", params[:start_date])
    end
    if params[:end_date].present?
      base_query = base_query.where("procedures.date <= ?", params[:end_date])
    end

    @procedures_for_display = base_query.order(date: :desc) # For optional detailed list

    # For totals, sum on the base_query before ordering or further manipulation for display
    @total_debit = base_query.sum(:debit) || 0
    @total_credit = base_query.sum(:credit) || 0
    @net_balance = @total_debit - @total_credit

    # For summary by client, group on the base_query
    summary_data = base_query
                     .joins(:client)
                     .group("clients.id", "clients.name") # Group by client id and name
                     .select("clients.name as client_name, SUM(procedures.debit) as total_debit, SUM(procedures.credit) as total_credit")
                     .order("clients.name")

    @financial_summary_by_client = summary_data.map do |item|
      OpenStruct.new(
        client_name: item.client_name,
        total_debit: item.total_debit,
        total_credit: item.total_credit
      )
    end
  end

  def birthdays
    # Logic for Birthdays Report
    @clients = Client.all

    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])

      start_md = start_date.strftime('%m-%d')
      end_md = end_date.strftime('%m-%d')

      if start_md <= end_md # Range does not cross year boundary (e.g., Mar-01 to Apr-15)
        @clients = @clients.where("strftime('%m-%d', birthdate) BETWEEN ? AND ?", start_md, end_md)
      else # Range crosses year boundary (e.g., Dec-01 to Jan-15)
        @clients = @clients.where("strftime('%m-%d', birthdate) >= ? OR strftime('%m-%d', birthdate) <= ?", start_md, end_md)
      end

    elsif params[:month].present? # Allow filtering by month number
        month_number = params[:month].to_i
        if month_number.between?(1,12)
            @clients = @clients.where("strftime('%m', birthdate) = ?", month_number.to_s.rjust(2, '0'))
        end
    end

    @clients = @clients.where.not(birthdate: nil).order(Arel.sql("strftime('%m-%d', birthdate) ASC, clients.name ASC"))
  end

  def procedures
    # Logic for Procedures Report
    @procedure_types = ProcedureType.order(:name) # For filter dropdown

    @query = Procedure.includes(:procedure_type, :client)

    if params[:procedure_type_id].present?
      @query = @query.where(procedure_type_id: params[:procedure_type_id])
    end
    if params[:start_date].present?
      @query = @query.where("date >= ?", params[:start_date])
    end
    if params[:end_date].present?
      @query = @query.where("date <= ?", params[:end_date])
    end

    # Summary: Count of each procedure type
    @procedures_summary = @query.joins(:procedure_type)
                                .group("procedure_types.name")
                                .count
                                .sort_by { |name, count| -count } # Sort by count descending

    # Detailed list of procedures matching filters (optional for display)
    @filtered_procedures = @query.order('procedures.date DESC', 'clients.name ASC')
  end
end
