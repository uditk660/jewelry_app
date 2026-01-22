class RatesController < ApplicationController
  def index
    # Build grouped rates by Metal -> Purity showing the most recent rate per combination
    @metals = Metal.order(:name).includes(:purities)
    @grouped_rates = {}
    @metals.each do |metal|
      @grouped_rates[metal.name] = metal.purities.order(:purity_percent).map do |pur|
        # Rates record metal_type as "MetalName - PurityName" (see create), so search that pattern
        pattern = "#{metal.name}%#{pur.name}%"
        rate = Rate.where('metal_type LIKE ?', pattern).order(date: :desc).first
        { purity: pur, rate: rate }
      end
    end
    render template: 'rates/index'
  end

  def new
  @rate = Rate.new(date: Time.zone.today)
  @metals = Metal.order(:name)
  # allow preselecting a metal via params[:metal_id]
  @selected_metal_id = params[:metal_id].present? ? params[:metal_id].to_i : (@metals.first ? @metals.first.id : nil)
  @selected_purity_id = params[:purity_id].present? ? params[:purity_id].to_i : nil
  @purities_for_metal = @selected_metal_id ? Metal.find(@selected_metal_id).purities.order(:purity_percent) : Purity.none
  # determine a sensible prefill price (rupees per gram) from latest Rate or Purity.updated_price
  @prefill_price = nil
  if @selected_metal_id && @selected_purity_id
    purity = Purity.find_by(id: @selected_purity_id)
    if purity
      metal = Metal.find_by(id: @selected_metal_id)
      if metal
        pattern = "#{metal.name}%#{purity.name}%"
        rate = Rate.where('metal_type LIKE ?', pattern).order(date: :desc).first
        @prefill_price = rate.price_per_gram if rate
      end
      @prefill_price ||= purity.updated_price.to_f if purity.respond_to?(:updated_price) && purity.updated_price.present?
    end
  end
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
      # if a purity was provided, persist its updated_price as well
      if params[:purity_id].present?
        purity = Purity.find_by(id: params[:purity_id])
        if purity && params[:price_per_gram].present?
          purity.updated_price = params[:price_per_gram].to_s.gsub(',', '').to_f
          purity.save
        end
      end
      redirect_to rates_path, notice: 'Rate saved.'
    else
      @metals = Metal.order(:name)
      @purities_for_metal = metal ? metal.purities.order(:purity_percent) : Purity.none
      render template: 'rates/new'
    end
  end

  def edit
    @rate = Rate.find(params[:id])
    @metals = Metal.order(:name)
    # prefer explicit params if provided (from index links), otherwise try to infer from rate.metal_type
    @selected_metal_id = params[:metal_id].present? ? params[:metal_id].to_i : nil
    @selected_purity_id = params[:purity_id].present? ? params[:purity_id].to_i : nil
    if @selected_metal_id.nil? || @selected_purity_id.nil?
      if @rate.metal_type.present?
        parts = @rate.metal_type.split('-').map(&:strip)
        if parts.size >= 2
          metal_name = parts[0]
          purity_name = parts[1]
          metal = Metal.find_by(name: metal_name)
          if metal
            @selected_metal_id ||= metal.id
            purity = metal.purities.find_by(name: purity_name)
            @selected_purity_id ||= (purity.id if purity)
          end
        end
      end
    end
    @purities_for_metal = @selected_metal_id ? Metal.find(@selected_metal_id).purities.order(:purity_percent) : Purity.none
    @prefill_price = @rate.price_per_gram
    render template: 'rates/edit'
  end

  def update
    @rate = Rate.find(params[:id])
    # build metal_type from params if provided
    if params[:metal_id].present?
      metal = Metal.find_by(id: params[:metal_id])
      purity = Purity.find_by(id: params[:purity_id]) if params[:purity_id].present?
      label = metal ? metal.name.dup : ''
      label += " - #{purity.name}" if purity
      @rate.metal_type = label.presence || params[:metal_type]
    end

    # handle price_per_gram input
    if params[:price_per_gram].present?
      rupees = params[:price_per_gram].to_s.gsub(',', '').to_f
      @rate.price_cents_per_gram = (rupees * 100).round
    end

    if @rate.update(rate_params)
      # update purity updated_price when provided
      if params[:purity_id].present? && params[:price_per_gram].present?
        purity = Purity.find_by(id: params[:purity_id])
        if purity
          purity.updated_price = params[:price_per_gram].to_s.gsub(',', '').to_f
          purity.save
        end
      end
      redirect_to rates_path, notice: 'Rate updated.'
    else
      @metals = Metal.order(:name)
      if @rate.metal_type.present?
        parts = @rate.metal_type.split('-').map(&:strip)
        if parts.any?
          metal = Metal.find_by(name: parts[0])
          @purities_for_metal = metal ? metal.purities.order(:purity_percent) : Purity.none
        else
          @purities_for_metal = Purity.none
        end
      else
        @purities_for_metal = Purity.none
      end
      render template: 'rates/edit'
    end
  end

  private
  def rate_params
  params.require(:rate).permit(:date, :metal_type)
  end
end
