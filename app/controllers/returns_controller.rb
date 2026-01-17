class ReturnsController < ApplicationController
  def index
    # show recent return records (for now we only load from session or flash)
    @records = (session[:return_records] || []).reverse
  end

  def new
    @return = OpenStruct.new(customer_id: params[:customer_id], order_id: params[:order_id], reason: nil, action: 'cash', amount: nil, notes: nil)
  end

  def create
    payload = params.require(:return).permit(:customer_id, :order_id, :reason, :action, :amount, :notes, :jewelry_item_id, :quantity)
    record = payload.to_h.merge(created_at: Time.zone.now)

    # If a jewelry_item and quantity are provided, update stock/quantity
    if payload[:jewelry_item_id].present? && payload[:quantity].present?
      ji = JewelryItem.find_by(id: payload[:jewelry_item_id])
      qty = payload[:quantity].to_i
      if ji && qty > 0
        # increment jewelry item quantity atomically
        JewelryItem.transaction do
          ji.lock!
          ji.quantity = (ji.quantity || 0) + qty
          ji.save!
        end

        # try to find an inventory_item for this jewelry_item and adjust grams if weight present
        inv = InventoryItem.find_by(jewelry_item_id: ji.id)
        if inv && ji.weight_grams.present?
          grams_to_add = (ji.weight_grams.to_f * qty).round
          inv.adjust!(grams_to_add, movement_type: 'return', note: "Return for order #{payload[:order_id]}")
        end

        record['stock_updated'] = true
      end
    end

    session[:return_records] ||= []
    session[:return_records] << record
    flash[:notice] = "Return recorded — #{record['action'].upcase}: #{record['amount'] || 'N/A'}"
    redirect_to returns_path
  end

  def show
    idx = params[:id].to_i
    @record = (session[:return_records] || [])[idx]
    unless @record
      redirect_to returns_path, alert: 'Return not found'
    end
  end
end
