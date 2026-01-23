class CustomersController < ApplicationController
  def index
    @q = params[:q].to_s.strip
    customers = Customer.order(:first_name, :last_name)
    if @q.present?
      q = "%#{@q.downcase}%"
      customers = customers.where('lower(first_name) LIKE ? OR lower(last_name) LIKE ? OR lower(email) LIKE ? OR phone LIKE ?', q, q, q, @q)
    end
    @customers = customers.limit(200)
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(params.require(:customer).permit(:first_name, :last_name, :email, :phone, :address))
    if @customer.save
      redirect_to customers_path, notice: 'Customer created'
    else
      render :new
    end
  end

  def show
    @customer = Customer.find(params[:id])
    @recent_orders = Order.where(customer_id: @customer.id).order(created_at: :desc).limit(10)
    # Tabbed orders list: all / paid / pending
    tab = params[:tab].to_s.downcase
    orders_scope = Order.where(customer_id: @customer.id).order(created_at: :desc)
    @orders = case tab
              when 'paid'
                orders_scope.where(status: 'paid')
              when 'pending'
                orders_scope.where(status: 'pending')
              else
                orders_scope
              end
    @payments = Payment.where(customer_id: @customer.id).order(created_at: :desc)
  end
end
