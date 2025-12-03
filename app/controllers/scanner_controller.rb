class ScannerController < ApplicationController
  def index
    @suppliers = Supplier.includes(:supplier_items)
    @ean       = params[:ean]

    @sessions = InventorySession.active.includes(:supplier).order(created_at: :desc)

    @current_session =
      if params[:inventory_session_id].present?
        InventorySession.active.find_by(id: params[:inventory_session_id]) || @sessions.first
      else
        @sessions.first
      end

    @scans =
      if @current_session
        @current_session.inventory_scans
                        .includes(:supplier, :supplier_item)
                        .order(created_at: :desc)
                        .limit(50)
      else
        InventoryScan.none
      end
  end

  def scan
    raw_ean = params[:ean].to_s

    # 1) On nettoie : on garde uniquement les chiffres
    cleaned_ean = raw_ean.gsub(/[^\d]/, "").strip
    @ean        = cleaned_ean

    Rails.logger.info "=== SCAN DEBUG raw='#{raw_ean}' cleaned='#{cleaned_ean}' length_raw=#{raw_ean.length} length_clean=#{cleaned_ean.length}"

    # 2) On retrouve la session courante (même logique que dans index)
    sessions =
      InventorySession.active.includes(:supplier).order(created_at: :desc)

    current_session =
      if params[:inventory_session_id].present?
        InventorySession.active.find_by(id: params[:inventory_session_id]) || sessions.first
      else
        sessions.first
      end

    # 3) On cherche d'abord un match exact sur l'EAN nettoyé (13 chiffres)
    item = nil

    if cleaned_ean.present?
      item = SupplierItem.includes(:supplier).find_by(ean: cleaned_ean)
    end

    # 4) Si pas trouvé et que l'EAN fait 13 chiffres,
    #    on tente l'ancien format Excel "xxxxx0"
    if item.nil? && cleaned_ean.length == 13
      alt_ean = "#{cleaned_ean}0"
      Rails.logger.info "=== SCAN ALT EAN '#{alt_ean}' ==="
      item = SupplierItem.includes(:supplier).find_by(ean: alt_ean)
    end

    if item
      @scan_result = {
        found:    true,
        supplier: item.supplier,
        item:     item
      }
    else
      @scan_result = { found: false }
    end

    # 5) On enregistre le scan dans l'inventaire si on a une session
    if current_session && cleaned_ean.present?
      InventoryScan.create!(
        inventory_session: current_session,
        ean:               cleaned_ean,
        found:             item.present?,
        supplier:          item&.supplier,
        supplier_item:     item
      )
    end

    # 6) On revient sur la page principale, avec la bonne session sélectionnée
    redirect_to root_path(inventory_session_id: current_session&.id, ean: cleaned_ean)
  end
end
