class InventoriesController < ApplicationController
  before_action :set_session, only: [:show, :export_found, :export_not_found, :archive]

def index
  @active_sessions   = InventorySession.active.includes(:supplier).order(created_at: :desc)
  @archived_sessions = InventorySession.archived.includes(:supplier).order(created_at: :desc)
end


  def show
    @scans = @session.inventory_scans.order(created_at: :desc)
  end

  def new
    @session   = InventorySession.new
    @suppliers = Supplier.order(:name)
  end

  def create
    @session = InventorySession.new(session_params)

    if @session.save
      redirect_to root_path, notice: "Session d'inventaire créée : #{@session.name}"
    else
      @suppliers = Supplier.order(:name)
      flash.now[:alert] = "Impossible de créer la session."
      render :new
    end
  end

  def export_found
    found = @session.inventory_scans.where(found: true)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["EAN", "Fournisseur", "Article"]
      found.each do |scan|
        csv << [
          scan.ean,
          scan.supplier&.name,
          scan.supplier_item&.name
        ]
      end
    end

    send_data csv_data,
              filename: "inventaire_trouves_#{Time.now.strftime('%Y%m%d_%H%M')}.csv",
              type: "text/csv"
  end

  def export_not_found
    not_found = @session.inventory_scans.where(found: false)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["EAN"]
      not_found.each do |scan|
        csv << [scan.ean]
      end
    end

    send_data csv_data,
              filename: "inventaire_non_trouves_#{Time.now.strftime('%Y%m%d_%H%M')}.csv",
              type: "text/csv"
  end

  def archive
    @session.update!(archived: true)
    redirect_to inventories_path, notice: "Session d'inventaire archivée : #{@session.name}"
  end

  private

  def set_session
    @session = InventorySession.find(params[:id])
  end

  def session_params
    params.require(:inventory_session).permit(:name, :supplier_id)
  end
end
