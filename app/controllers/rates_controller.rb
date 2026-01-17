class RatesController < ApplicationController
  def index
    @rates = Rate.order(date: :desc)
    render template: 'rates/index'
  end

  def new
  @rate = Rate.new(date: Time.zone.today)
  @metals = Metal.order(:name)
  # allow preselecting a metal via params[:metal_id]
  @selected_metal_id = params[:metal_id].present? ? params[:metal_id].to_i : (@metals.first ? @metals.first.id : nil)
  @purities_for_metal = @selected_metal_id ? Metal.find(@selected_metal_id).purities.order(:purity_percent) : Purity.none
  render template: 'rates/new'
  end

  def create
    @rate = Rate.new(rate_params)

    # Build metal_type from selected metal and purity (if provided)
    if params[:metal_id].present?
      metal = Metal.find_by(id: params[:metal_id])
      purity = Purity.find_by(id: params[:purity_id]) if params[:purity_id].present?
      label = metal ? metal.name.dup : ''
      label += " - #{purity.name}" if purity
      @rate.metal_type = label.presence || params[:metal_type]
    end

    # Accept price input as rupees per gram from the form and convert to cents
    if params[:price_per_gram].present?
      rupees = params[:price_per_gram].to_s.gsub(',', '').to_f
      @rate.price_cents_per_gram = (rupees * 100).round
    end

    if @rate.save
      redirect_to rates_path, notice: 'Rate saved.'
    else
      @metals = Metal.order(:name)
      @purities_for_metal = metal ? metal.purities.order(:purity_percent) : Purity.none
      render template: 'rates/new'
    end
  end

  def edit
    @rate = Rate.find(params[:id])
    render template: 'rates/edit'
  end

  def update
    @rate = Rate.find(params[:id])
    if @rate.update(rate_params)
      redirect_to rates_path, notice: 'Rate updated.'
    else
      render template: 'rates/edit'
    end
  end

  private
  def rate_params
  params.require(:rate).permit(:date, :metal_type)
  end
end
