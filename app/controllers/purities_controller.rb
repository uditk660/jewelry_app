class PuritiesController < ApplicationController
  def index
    @purities = Purity.order(:name)
    render template: 'purities/index'
  end

  def new
    @purity = Purity.new
    @metals = Metal.order(:name)
    render template: 'purities/new'
  end

  def create
    @purity = Purity.new(purity_params)
    if @purity.save
      redirect_to purities_path, notice: 'Purity created.'
    else
      @metals = Metal.order(:name)
      render template: 'purities/new'
    end
  end

  private
  def purity_params
    params.require(:purity).permit(:metal_id, :name, :purity_percent, :active, :updated_price, :remarks)
  end
end
