Metal.find_or_create_by!(name: 'Gold') do |m|
  m.base_unit = 'gram'
  m.active = true
end

Metal.find_or_create_by!(name: 'Silver') do |m|
  m.base_unit = 'gram'
  m.active = true
end

# sample purities
if Metal.count > 0
  gold = Metal.find_by(name: 'Gold')
  Purity.find_or_create_by!(metal: gold, name: '22K') do |p|
    p.purity_percent = 91.667
    p.active = true
  end
  Purity.find_or_create_by!(metal: gold, name: '18K') do |p|
    p.purity_percent = 75.0
    p.active = true
  end
  silver = Metal.find_by(name: 'Silver')
  Purity.find_or_create_by!(metal: silver, name: 'Sterling') do |p|
    p.purity_percent = 92.5
    p.active = true
  end
end
