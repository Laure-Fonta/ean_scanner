class InventoryScansController < ApplicationController
  def destroy
    scan = InventoryScan.find(params[:id])
    session_id = scan.inventory_session_id

    scan.destroy!
    redirect_to root_path(inventory_session_id: session_id), notice: "Scan supprimé."
  end
end
