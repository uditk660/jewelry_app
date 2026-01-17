class ReportsController < ApplicationController
  def index
    render plain: 'Reports index (placeholder)'
  end

  def new
    render plain: 'New report (placeholder)'
  end

  def sales_log
    # base scope — consider only paid orders
    scope = Order.where(status: 'paid')

    today = Time.zone.today
    @today_total = scope.where(sale_date: today).sum(&:total)
    @yesterday_total = scope.where(sale_date: today - 1).sum(&:total)

    # week: monday..sunday
    week_start = today.beginning_of_week
    week_end = today.end_of_week
    @week_total = scope.where(sale_date: week_start..week_end).sum(&:total)

    @month_total = scope.where(sale_date: today.beginning_of_month..today.end_of_month).sum(&:total)
    @year_total = scope.where(sale_date: today.beginning_of_year..today.end_of_year).sum(&:total)

    # custom range
    if params[:from].present? && params[:to].present?
      from = Date.parse(params[:from]) rescue nil
      to = Date.parse(params[:to]) rescue nil
      if from && to
        @custom_total = scope.where(sale_date: from..to).sum(&:total)
        @custom_range = [from, to]
      end
    end
    # Item-wise aggregates for the week
    @top_items_week = LineItem.joins(:order, :jewelry_item)
                             .where(orders: { status: 'paid', sale_date: week_start..week_end })
                             .group('jewelry_items.id', 'jewelry_items.name')
                             .select('jewelry_items.id, jewelry_items.name, SUM(line_items.quantity) as qty_sold, SUM(line_items.price_cents * line_items.quantity)/100.0 as sales_amount')
                             .order('SUM(line_items.quantity) DESC')

      if @custom_range
        @top_items_custom = LineItem.joins(:order, :jewelry_item)
                                     .where(orders: { status: 'paid', sale_date: @custom_range[0]..@custom_range[1] })
                                     .group('jewelry_items.id', 'jewelry_items.name')
                                     .select('jewelry_items.id, jewelry_items.name, SUM(line_items.quantity) as qty_sold, SUM(line_items.price_cents * line_items.quantity)/100.0 as sales_amount')
                                    .order('SUM(line_items.quantity) DESC')
      else
        @top_items_custom = []
      end
  end
end
