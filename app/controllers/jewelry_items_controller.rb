class JewelryItemsController < ApplicationController
  protect_from_forgery with: :exception

  def index
    # simple search, sort and pagination
    per_page = (params[:per_page] || 25).to_i
    page = (params[:page].to_i <= 0) ? 1 : params[:page].to_i
    query = params[:q].to_s.strip

  # eager load associations and metal -> metal_stocks -> store to avoid N+1 when rendering stock breakdown
  items = JewelryItem.includes(:purity, :jewellery_category, metal: { metal_stocks: :store })

    if query.present?
      items = items.joins("LEFT JOIN jewellery_categories ON jewellery_categories.id = jewelry_items.jewellery_category_id")
                   .joins("LEFT JOIN metals ON metals.id = jewelry_items.metal_id")
                   .joins("LEFT JOIN purities ON purities.id = jewelry_items.purity_id")
                   .where("jewelry_items.name LIKE :q OR jewelry_items.sku LIKE :q OR jewelry_items.description LIKE :q OR jewellery_categories.name LIKE :q OR metals.name LIKE :q OR purities.name LIKE :q", q: "%#{query}%")
    end

    sort = params[:sort].to_s
    direction = params[:direction] == 'asc' ? 'ASC' : 'DESC'

    case sort
    when 'weight'
      items = items.order("weight_grams #{direction}")
    when 'price'
      items = items.order("price_cents #{direction}")
    when 'available'
      # available_sort_value: prefer `quantity` (pcs), else sum of metal stock available_grams
      items = items.select("jewelry_items.*, COALESCE(jewelry_items.quantity, (SELECT SUM(available_grams) FROM metal_stocks WHERE metal_stocks.metal_id = jewelry_items.metal_id), 0) AS available_sort_value")
                   .order("available_sort_value #{direction}")
    else
      items = items.order(created_at: :desc)
    end

    @total_count = items.except(:limit, :offset, :order).count
    @page = page
    @per_page = per_page
  @start_index = (@page - 1) * @per_page
    @items = items.limit(per_page).offset((page - 1) * per_page)

    render template: 'jewelry_items/index'
  end

  def show
    @item = JewelryItem.find(params[:id])
    render template: 'jewelry_items/show'
  end

  def new
    @item = JewelryItem.new
    @metals = Metal.order(:name)
    @purities = Purity.order(:name)
    render template: 'jewelry_items/new'
  end

  def create
    # Support batch creation via params[:items] (array of hashes) with shared metal_id/purity_id
    if params[:items].present?
      # shared metal/purity are submitted under the `jewelry_item` form namespace
      if params[:jewelry_item].present?
        shared = params.require(:jewelry_item).permit(:metal_id, :purity_id, :jewellery_category_id).to_h
      else
        shared = params.permit(:metal_id, :purity_id, :jewellery_category_id).to_h
      end
      # permit each item hash explicitly
      permitted_items = (params[:items] || []).map do |it|
        ActionController::Parameters.new(it).permit(:name, :sku, :quantity, :weight_grams, :description).to_h
      end
      created = []
      errors = []
      JewelryItem.transaction do
        permitted_items.each_with_index do |it, idx|
          attrs = it.to_h.merge(shared)
          # normalize numeric values
          attrs['quantity'] = attrs['quantity'].to_i if attrs.key?('quantity')
          attrs['weight_grams'] = attrs['weight_grams'].present? ? attrs['weight_grams'].to_f : nil
          # ensure SKU present (generate if blank)
          if attrs['sku'].blank?
            attrs['sku'] = SecureRandom.alphanumeric(5).upcase
          end
          ji = JewelryItem.new(attrs)
          unless ji.save
            errors << "Row #{idx + 1}: #{ji.errors.full_messages.join(', ')}"
            raise ActiveRecord::Rollback
          end
          created << ji
        end
      end

      if errors.empty?
        if created.size == 1
          redirect_to created.first and return
        else
          redirect_to jewelry_items_path, notice: "Created #{created.size} items" and return
        end
      else
        flash.now[:error] = errors.join(' ; ')
        @metals = Metal.order(:name)
        @purities = Purity.order(:name)
        @item = JewelryItem.new
        render template: 'jewelry_items/new' and return
      end
    end

    @item = JewelryItem.new(jewelry_item_params)
    if @item.save
      redirect_to @item
    else
      @metals = Metal.order(:name)
      @purities = Purity.order(:name)
      render template: 'jewelry_items/new'
    end
  end

  def edit
    @item = JewelryItem.find(params[:id])
    @metals = Metal.order(:name)
    @purities = Purity.order(:name)
    render template: 'jewelry_items/edit'
  end

  def update
    @item = JewelryItem.find(params[:id])
    if @item.update(jewelry_item_params)
      redirect_to @item
    else
      @metals = Metal.order(:name)
      @purities = Purity.order(:name)
      render template: 'jewelry_items/edit'
    end
  end

  def destroy
    @item = JewelryItem.find(params[:id])
    @item.destroy
    redirect_to jewelry_items_path
  end

  private

  def jewelry_item_params
    params.require(:jewelry_item).permit(:name, :description, :price_cents, :sku, :quantity, :metal_id, :purity_id, :jewellery_category_id, :weight_grams)
  end
end
