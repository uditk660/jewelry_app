item = JewelryItem.where('quantity > 0').first
if item.nil?
  puts 'No jewelry_item with quantity > 0 found; aborting test.'
  exit 1
end
puts "Found item #{item.id} qty=#{item.quantity}"
customer = Customer.first || Customer.create!(first_name: 'Walk', last_name: 'In', phone: '0000000000', email: 'walkin@example.com')
order = Order.create!(status: 'pending', customer: customer)
li = order.line_items.create!(jewelry_item: item, price_cents: item.price_cents, quantity: 1, weight: 1.0)
puts "Created order #{order.id} with line_item #{li.id}; item qty before=#{item.quantity}"
order.update(status: 'paid')
item.reload
puts "After marking paid, item qty now=#{item.quantity}"
puts "Order previous_changes: #{order.previous_changes.inspect}"
puts "Order saved_changes: #{order.saved_changes.inspect} if order.respond_to?(:saved_changes)"
