class PublicInvoicesController < ApplicationController
  # allow public access
  skip_before_action :authenticate_user!

  def show
    token = params[:token]
    verifier = Rails.application.message_verifier(:invoices)
    payload = verifier.verify(token)

    # payload should include order_id and exp (unix timestamp)
    order_id = (payload[:order_id] || payload['order_id']) rescue nil
    exp = (payload[:exp] || payload['exp']) rescue nil

    if order_id.nil? || exp.nil? || Time.at(exp) < Time.current
      return head :not_found
    end

    @order = Order.find_by(id: order_id)
    return head :not_found unless @order

    respond_to do |format|
      format.html { redirect_to invoice_order_path(@order) }
      format.pdf do
        render pdf: "invoice_#{@order.id}",
               template: 'orders/invoice',
               layout: 'pdf',
               disposition: 'inline'
      end
    end
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveSupport::MessageVerifier::InvalidMessage
    head :not_found
  end
end
