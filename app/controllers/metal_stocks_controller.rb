class MetalStocksController < ApplicationController
  def index
    @metal_stocks = MetalStock.includes(:metal, :store).order('stores.name, metals.name')
  end

  def new
    @metal_stock = MetalStock.new
    @metals = Metal.order(:name)
    @stores = Store.order(:name)
  end

  def create
    @metal_stock = MetalStock.new(metal_stock_params)
    if @metal_stock.save
      redirect_to metal_stocks_path, notice: 'Stock record created.'
    else
      @metals = Metal.order(:name)
      @stores = Store.order(:name)
      render :new
    end
  end

  def adjust
    @metal_stock = MetalStock.find(params[:id])
  end

  def do_adjust
    @metal_stock = MetalStock.find(params[:id])
    change = params.require(:metal_stock).fetch(:change_grams).to_i
    note = params[:metal_stock][:note]
    @metal_stock.adjust!(change, movement_type: 'manual', note: note)
    redirect_to metal_stocks_path, notice: 'Stock adjusted.'
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.message
    render :adjust
  end

  private
  def metal_stock_params
    params.require(:metal_stock).permit(:metal_id, :store_id, :available_grams, :price_cents_per_gram)
  end
end
