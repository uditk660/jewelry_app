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

    @order.update(discount: params[:discount].to_f, charges: params[:charges].to_f, cgst_rate: cgst_rate, igst_rate: igst_rate)
    # compute and persist tax cents
    @order.update_columns(cgst_cents: @order.cgst_amount_cents(cgst_rate), igst_cents: @order.igst_amount_cents(igst_rate))
    @order.update(status: 'paid')

    redirect_to invoice_order_path(@order)
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
      # try to find existing by phone or email
      customer = Customer.find_by(phone: cust_attrs[:phone]) || Customer.find_by(email: cust_attrs[:email])
      unless customer
        # prefer phone if present, else email as uniqueness key
        if cust_attrs[:phone].present?
          customer = Customer.find_or_create_by(phone: cust_attrs[:phone]) do |c|
            c.assign_attributes(cust_attrs)
          end
        elsif cust_attrs[:email].present?
          customer = Customer.find_or_create_by(email: cust_attrs[:email]) do |c|
            c.assign_attributes(cust_attrs)
          end
        else
          customer = Customer.create(cust_attrs)
        end
      end
      # if customer creation failed due to validation, attach errors and re-render
      if customer && !customer.persisted?
        @order.errors.add(:base, "Customer invalid: ")
        customer.errors.full_messages.each { |m| @order.errors.add(:base, m) }
        @items = JewelryItem.available_for_sale.order(:name)
        @customers = Customer.order(:first_name, :last_name).limit(200)
        render template: 'orders/new' and return
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
        hsn = li[:hsn].to_s
  huid = li[:huid].to_s
  rate = li[:rate].to_s
        # only add if enough per-piece quantity is available
          if ji.quantity.to_i >= qty && qty > 0
          @order.line_items.create!(jewelry_item: ji, price_cents: ji.price_cents, quantity: qty, weight: nwt, gross_weight: gwt, net_weight: nwt, making_charge: making, hsn: hsn, huid: huid, rate: rate)
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
