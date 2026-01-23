class PaymentsController < ApplicationController
  def show
    @payment = Payment.find(params[:id])
    render template: 'payments/show'
  end

  def invoice
    @payment = Payment.find(params[:id])
    render template: 'payments/invoice', layout: 'application'
  end
end
