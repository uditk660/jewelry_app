items = [
  { name: 'Classic Gold Ring', description: '14k gold band', price_cents: 19900, sku: 'RING-001', weight_grams: 5, metal_type: 'gold' },
  { name: 'Sapphire Necklace', description: '925 silver with sapphire', price_cents: 49900, sku: 'NECK-002', weight_grams: 30, metal_type: 'silver' },
  { name: 'Diamond Studs', description: '0.5ct diamonds', price_cents: 129900, sku: 'EARR-003', weight_grams: 2, metal_type: 'gold' }
]

items.each do |attrs|
  ji = JewelryItem.find_or_create_by!(sku: attrs[:sku]) do |i|
    i.name = attrs[:name]
    i.description = attrs[:description]
    i.price_cents = attrs[:price_cents]
    i.weight_grams = attrs[:weight_grams]
    i.metal_type = attrs[:metal_type]
  end
  ji.update(attrs.slice(:name, :description, :price_cents, :weight_grams, :metal_type))
end

Rate.find_or_create_by!(date: Time.zone.today, metal_type: 'gold') do |r|
  r.price_cents_per_gram = 6000
end
Rate.find_or_create_by!(date: Time.zone.today, metal_type: 'silver') do |r|
  r.price_cents_per_gram = 80
end

JewelryItem.find_each do |ji|
  InventoryItem.find_or_create_by!(jewelry_item: ji) do |inv|
    inv.available_grams = ji.weight_grams.to_i * 10
    inv.location = 'Main Store'
  end
end

require_relative 'seeds_metals'

# Create a default admin user for development
if defined?(User)
  User.find_or_create_by!(email: 'admin@example.com') do |u|
    u.password = 'password123'
    u.password_confirmation = 'password123'
  end
end

# Default store
store = Store.find_or_create_by!(name: 'Main Store') do |s|
  s.location = 'Head Office'
end

# Seed metal stocks for each existing metal (0 grams, price from today's rate if present)
Metal.find_each do |m|
  ms = MetalStock.find_or_create_by!(metal: m, store: store) do |rec|
    rec.available_grams = 0
    rate = Rate.where(metal_type: m.name.downcase).order(date: :desc).first
    rec.price_cents_per_gram = rate ? rate.price_cents_per_gram : 0
  end
  ms.update(price_cents_per_gram: ms.price_cents_per_gram || 0)
end

