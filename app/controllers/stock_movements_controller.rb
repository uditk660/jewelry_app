class StockMovementsController < ApplicationController
  def create
    @inventory_item = InventoryItem.find(params[:inventory_item_id])
    grams = params[:change_grams].to_i
    type = params[:movement_type] || 'adjustment'
    note = params[:note]

    @inventory_item.adjust!(grams, movement_type: type, note: note)
    redirect_to inventory_item_path(@inventory_item), notice: 'Inventory adjusted.'
  end
end
