class LedgersController < ApplicationController
  def index
    @entries = []
    render plain: 'Ledger index (placeholder)'
  end

  def new
    render plain: 'New ledger entry (placeholder)'
  end
end
