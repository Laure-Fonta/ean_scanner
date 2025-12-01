class ScannerController < ApplicationController
  def index
    @suppliers = Supplier.includes(:supplier_items)
    @ean       = nil

    @sessions = InventorySession.active.includes(:supplier).order(created_at: :desc)

    @current_session =
      if params[:inventory_session_id].present?
        InventorySession.active.find_by(id: params[:inventory_session_id]) || @sessions.first
      else
        @sessions.first
      end

    @scans =
      if @current_session
        @current_session.inventory_scans.order(created_at: :desc).limit(50)
      else
        InventoryScan.none
      end
  end

  def scan
    @ean = params[:ean].to_s.strip

    sessions = InventorySession.active.order(created_at: :desc)
    current_session =
      if params[:inventory_session_id].present?
        InventorySession.active.find_by(id: params[:inventory_session_id]) || sessions.first
      else
        sessions.first
      end

    if current_session && @ean.present?
      item = SupplierItem.includes(:supplier).find_by(ean: @ean)

      if item
        InventoryScan.create!(
          inventory_session: current_session,
          ean:               @ean,
          found:             true,
          supplier:          item.supplier,
          supplier_item:     item
        )
      else
        InventoryScan.create!(
          inventory_session: current_session,
          ean:               @ean,
          found:             false
        )
      end
    end

    # On revient toujours sur la page d’accueil, avec la bonne session sélectionnée
    redirect_to root_path(inventory_session_id: current_session&.id)
  end
end
