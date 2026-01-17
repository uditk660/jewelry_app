class StoresController < ApplicationController
  def index
    @stores = Store.order(:name)
  end

  def new
    @store = Store.new
  end

  def create
    @store = Store.new(store_params)
    if @store.save
      redirect_to stores_path, notice: 'Store created.'
    else
      render :new
    end
  end

  private
  def store_params
    params.require(:store).permit(:name, :location)
  end
end
