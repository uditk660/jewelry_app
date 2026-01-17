# Seed an example order if jewelry items exist
if JewelryItem.count > 0
  item = JewelryItem.first
  o = Order.create!(status: 'pending')
  o.line_items.create!(jewelry_item: item, price_cents: item.price_cents, quantity: 1)
  puts "Created sample order ##{o.id}"
end
