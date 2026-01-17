class InventoryItemsController < ApplicationController
  def index
  # Ensure ordering by associated jewelry_items.name works across DB adapters
  @inventory_items = InventoryItem.includes(:jewelry_item).references(:jewelry_item).order('jewelry_items.name ASC')
    render template: 'inventory_items/index'
  end

  def new
    @inventory_item = InventoryItem.new
    @items = JewelryItem.order(:name)
    render template: 'inventory_items/new'
  end

  def create
    @inventory_item = InventoryItem.new(inventory_item_params)
    if @inventory_item.save
      redirect_to inventory_items_path, notice: 'Inventory item created.'
    else
      @items = JewelryItem.order(:name)
      render template: 'inventory_items/new'
    end
  end

  def show
    @inventory_item = InventoryItem.find(params[:id])
    render template: 'inventory_items/show'
  end

  private
  def inventory_item_params
    params.require(:inventory_item).permit(:jewelry_item_id, :available_grams, :location)
  end
end
