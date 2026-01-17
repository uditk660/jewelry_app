class MetalsController < ApplicationController
  def index
    @metals = Metal.order(:name)
    render template: 'metals/index'
  end

  def new
    @metal = Metal.new
    render template: 'metals/new'
  end

  def show
    @metal = Metal.find(params[:id])
    render template: 'metals/show'
  end

  def destroy
    @metal = Metal.find(params[:id])
    @metal.destroy
    redirect_to metals_path, notice: 'Metal deleted.'
  end

  def create
    @metal = Metal.new(metal_params)
    if @metal.save
      redirect_to metals_path, notice: 'Metal created.'
    else
      render template: 'metals/new'
    end
  end

  private
  def metal_params
    params.require(:metal).permit(:name, :base_unit, :active)
  end
end
