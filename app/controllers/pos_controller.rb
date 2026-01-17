class PosController < ApplicationController
  # POS landing page
  def index
    # show a simple terminal view (use orders/new for quick order creation)
  @items = JewelryItem.available_for_sale.order(:name)
    render template: 'pos/index'
  end

  # POST /pos/create_order
  def create_order
    # expected params: items => [{jewelry_item_id, quantity}], discount, charges, gross_weight, net_weight
    order = Order.create!(status: 'pending')
    params.fetch(:items, []).each do |it|
      ji = JewelryItem.find(it[:jewelry_item_id])
      qty = it[:quantity].to_i
      weight = it[:weight].to_f
      # only create line if item has quantity or enough stock
      if ji.quantity.nil? || ji.quantity <= 0 || ji.quantity >= qty
        order.line_items.create!(jewelry_item: ji, price_cents: ji.price_cents, quantity: qty, weight: weight)
      end
    end
  order.update(discount: params[:discount].to_f, charges: params[:charges].to_f, gross_weight: params[:gross_weight].to_f, net_weight: params[:net_weight].to_f, cgst_rate: params[:cgst_rate].to_f, igst_rate: params[:igst_rate].to_f)
  # compute and persist tax cents
  order.update_columns(cgst_cents: order.cgst_amount_cents(order.cgst_rate), igst_cents: order.igst_amount_cents(order.igst_rate))
    redirect_to order_path(order)
  rescue ActiveRecord::RecordInvalid => e
    redirect_to pos_path, alert: "Could not create order: #{e.message}"
  end

  # POST /pos/charge
  # params: order_id, payment (hash)
  def charge
    @order = Order.find(params[:order_id])
    payment_info = params[:payment] || {}

    result = BillingService.new(@order, payment_info).charge!
    if result[:success]
  # update status to 'paid' - Order#after_update will handle inventory decrement atomically
  @order.update(status: 'paid')
      redirect_to @order, notice: 'Payment processed successfully.'
    else
      @order.update(status: 'failed')
      redirect_to @order, alert: "Payment failed: #{result[:error]}"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path, alert: 'Order not found'
  end
end
