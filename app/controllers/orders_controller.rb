class OrdersController < ApplicationController
  protect_from_forgery with: :exception

  def index
    @q = params[:q].to_s.strip
    if @q.present?
      q = @q.strip
      parsed_date = nil
      begin
        parsed_date = Date.parse(q) if q =~ /\A\d{4}-\d{2}-\d{2}\z/
      rescue ArgumentError
        parsed_date = nil
      end

      orders = Order.left_joins(line_items: :jewelry_item).distinct

      clauses = []
      args = {}

      # order id exact match when numeric
      if q =~ /\A\d+\z/
        clauses << 'orders.id = :oid'
        args[:oid] = q.to_i
      end

      # status exact match
      if Order::STATUSES.map(&:downcase).include?(q.downcase)
        clauses << 'lower(orders.status) = :status'
        args[:status] = q.downcase
      end

      # date exact match (YYYY-MM-DD)
      if parsed_date
        clauses << 'orders.created_at BETWEEN :dstart AND :dend'
        args[:dstart] = parsed_date.beginning_of_day
        args[:dend] = parsed_date.end_of_day
      end

      # item name partial match (case-insensitive)
      clauses << 'lower(jewelry_items.name) LIKE :iname'
      args[:iname] = "%#{q.downcase}%"

      @orders = orders.where(clauses.join(' OR '), args).order(created_at: :desc)
    else
      @orders = Order.order(created_at: :desc)
    end

    # total sales today (paid orders)
    # use Time.zone.today and the order's sale_date (set at creation) to avoid created_at timezone mismatches
    today = Time.zone.today
    paid_today = Order.where(status: 'paid', sale_date: today)
    # sum using the model helper to include taxes (uses stored cgst/igst cents if present)
    @today_total = paid_today.to_a.sum do |o|
      # prefer stored cents if available, else compute using rates
      if o.respond_to?(:cgst_cents) && o.respond_to?(:igst_cents)
        cents = o.subtotal_cents - (o.discount.to_f * 100).to_i + (o.charges.to_f * 100).to_i + (o.cgst_cents.to_i) + (o.igst_cents.to_i)
        cents.to_f / 100.0
      else
        o.total_with_taxes(cgst_rate: o.cgst_rate.to_f, igst_rate: o.igst_rate.to_f)
      end
    end
    render template: 'orders/index'
  end

  def show
    @order = Order.find(params[:id])
    render template: 'orders/show'
  end

  # POST /orders/:id/record_payment
  def record_payment
    @order = Order.find(params[:id])
    # accept either rates or explicit cents
    cgst_rate = params[:cgst_rate].to_f
    igst_rate = params[:igst_rate].to_f
    update_attrs = { discount: params[:discount].to_f, charges: params[:charges].to_f, cgst_rate: cgst_rate, igst_rate: igst_rate }
    pm = params[:payment_method].to_s
    if @order.respond_to?(:payment_method=)
      if pm.blank?
        @order.errors.add(:payment_method, 'must be selected')
        @order.assign_attributes(update_attrs)
        return render :show
      end
      update_attrs[:payment_method] = pm
    end

    @order.update(update_attrs)
    # compute and persist tax cents (use provided rates)
    @order.update_columns(cgst_cents: @order.cgst_amount_cents(cgst_rate), igst_cents: @order.igst_amount_cents(igst_rate))

    # parse payment amount
    pay_amt = (params[:payment_amount].to_f || 0.0)
    if pay_amt <= 0
      @order.errors.add(:base, 'Payment amount must be greater than 0')
      return render :show
    end

    # compute remaining before adding this payment
    remaining_cents = @order.remaining_cents.to_i
    pay_cents = (pay_amt * 100).to_i
    if pay_cents > remaining_cents
      @order.errors.add(:base, "Payment cannot exceed remaining amount (₹#{'%.2f' % (remaining_cents.to_f/100.0)})")
      return render :show
    end

    Payment.transaction do
      p = Payment.create!(order_id: @order.id, customer_id: @order.customer_id, amount_cents: pay_cents, payment_method: pm)
      # generate a receipt number and persist it on the payment (unique)
      rn = "RCT-#{Time.zone.today.strftime('%Y%m%d')}-#{p.id.to_s.rjust(4,'0')}"
      p.update_columns(receipt_number: rn)
      # decide if fully paid
      paid = @order.payments.sum(:amount_cents).to_i
      total = @order.total_cents_with_taxes(cgst_rate: (@order.cgst_rate || @order.cgst_rate_or_default), igst_rate: (@order.igst_rate || @order.igst_rate_or_default))
      # If stored cgst_cents/igst_cents present, prefer order.total_cents_with_taxes_cached
      total = @order.total_cents_with_taxes_cached if @order.respond_to?(:total_cents_with_taxes_cached)

      if paid >= total
        @order.update(status: 'paid')
      else
        # leave as pending (partial payment recorded)
        @order.update(status: 'pending')
      end

      # recompute customer outstanding balance
      if @order.customer
        @order.customer.recompute_balance!
      end
    end

    # redirect: if fully paid, show invoice; otherwise back to order with notice
    if @order.status == 'paid'
      redirect_to invoice_order_path(@order)
    else
      redirect_to @order, notice: 'Partial payment recorded. Receipt generated and linked in payments history.'
    end
  end

  def invoice
    @order = Order.find(params[:id])
  render template: 'orders/invoice', layout: 'application'
  end

  def new
    @order = Order.new(status: 'pending')
  @items = JewelryItem.available_for_sale.order(:name)
  @customers = Customer.order(:first_name, :last_name).limit(200)
  render template: 'orders/new'
  end

  def create
    @order = Order.new(status: 'pending')
  # Customer handling: either select existing by id or create new from form
    if params[:existing_customer_id].present?
      @order.customer_id = params[:existing_customer_id]
    elsif params[:customer].present?
      cust_attrs = params.require(:customer).permit(:first_name, :last_name, :address, :aadhaar_or_pan, :gst_number, :email, :phone)
      # Prefer matching existing customer by phone, then email
      customer = nil
      if cust_attrs[:phone].present?
        customer = Customer.find_by(phone: cust_attrs[:phone])
      end
      if customer.nil? && cust_attrs[:email].present?
        customer = Customer.find_by(email: cust_attrs[:email])
      end

      # If no existing customer, build and attempt to save a new one
      if customer.nil?
        customer = Customer.new(cust_attrs)
        unless customer.save
          @order.errors.add(:base, "Customer invalid: #{customer.errors.full_messages.join(', ')}")
          @items = JewelryItem.available_for_sale.order(:name)
          @customers = Customer.order(:first_name, :last_name).limit(200)
          render template: 'orders/new' and return
        end
      end

      @order.customer = customer
    end
    # enforce presence of customer server-side
    unless @order.customer_id.present?
      @order.errors.add(:base, 'Customer must be selected or created before placing an order')
      @items = JewelryItem.available_for_sale.order(:name)
      @customers = Customer.order(:first_name, :last_name).limit(200)
      render template: 'orders/new' and return
    end
    # remaining numeric fields still accepted if provided by other flows
    @order.discount = params[:discount].to_f if params[:discount].present?
    @order.charges = params[:charges].to_f if params[:charges].present?
    @order.gross_weight = params[:gross_weight].to_f if params[:gross_weight].present?
    @order.net_weight = params[:net_weight].to_f if params[:net_weight].present?
    @order.cgst_rate = params[:cgst_rate].to_f if params[:cgst_rate].present?
    @order.igst_rate = params[:igst_rate].to_f if params[:igst_rate].present?
  if @order.save
  # compute taxes and store cents
  cgst_c = @order.cgst_amount_cents(@order.cgst_rate)
  igst_c = @order.igst_amount_cents(@order.igst_rate)
  @order.update_columns(cgst_cents: cgst_c, igst_cents: igst_c)
      created = 0
      (params[:line_items] || []).each do |li|
        next unless li[:jewelry_item_id].present?
  ji = JewelryItem.find(li[:jewelry_item_id])
        qty = li[:quantity].to_i
        gwt = li[:gross_weight].to_f
        nwt = li[:net_weight].to_f
        making = li[:making_charge].to_f
    additional = li[:additional_charge].to_f
    hsn = li[:hsn].to_s
  huid = li[:huid].to_s
  rate = li[:rate].to_s
    # fallback to catalog item's HSN when incoming param is blank
    hsn = ji.try(:hsn).to_s if hsn.blank? && ji.respond_to?(:hsn)
        # only add if enough per-piece quantity is available
          if ji.quantity.to_i >= qty && qty > 0
          @order.line_items.create!(jewelry_item: ji, price_cents: ji.price_cents, quantity: qty, weight: nwt, gross_weight: gwt, net_weight: nwt, making_charge: making, additional_charge: additional, hsn: hsn, huid: huid, rate: rate)
          created += 1
        end
      end
      if created == 0
        @order.destroy
        @order = Order.new(status: 'pending')
        @order.errors.add(:base, 'No items could be added to the order (insufficient stock or invalid quantities)')
        @items = JewelryItem.available_for_sale.order(:name)
        @customers = Customer.order(:first_name, :last_name).limit(200)
        render template: 'orders/new' and return
      end
      # compute taxes and store cents
      cgst_c = @order.cgst_amount_cents(@order.cgst_rate)
      igst_c = @order.igst_amount_cents(@order.igst_rate)
      @order.update_columns(cgst_cents: cgst_c, igst_cents: igst_c)
      redirect_to @order
    else
  @items = JewelryItem.order(:name)
      render template: 'orders/new'
    end
  end
end
