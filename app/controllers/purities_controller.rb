class PuritiesController < ApplicationController
  before_action :set_purity, only: [:show, :edit, :update]
  def index
    @purities = Purity.order(:name)
    render template: 'purities/index'
  end

  def new
    @purity = Purity.new
    @metals = Metal.order(:name)
    render template: 'purities/new'
  end

  def show
    render template: 'purities/show'
  end

  def edit
    @metals = Metal.order(:name)
    render template: 'purities/edit'
  end

  def update
    if @purity.update(purity_params)
      redirect_to purity_path(@purity), notice: 'Purity updated.'
    else
      @metals = Metal.order(:name)
      render template: 'purities/edit'
    end
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
  def set_purity
    @purity = Purity.find_by(id: params[:id])
    unless @purity
      redirect_to purities_path, alert: 'Purity not found.' and return
    end
  end
  def purity_params
    params.require(:purity).permit(:metal_id, :name, :purity_percent, :active, :updated_price, :total_weight, :remarks)
  end
end
