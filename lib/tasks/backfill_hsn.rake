# Backfill HSN on line_items from jewelry_items
namespace :data do
  desc 'Backfill line_items.hsn from jewelry_items.hsn when blank'
  task backfill_line_item_hsn: :environment do
    puts 'Starting backfill of line_items.hsn from jewelry_items.hsn...'
    cnt = 0
    LineItem.includes(:jewelry_item).find_each do |li|
      if li.hsn.blank? && li.jewelry_item && li.jewelry_item.respond_to?(:hsn) && li.jewelry_item.hsn.present?
        li.update_column(:hsn, li.jewelry_item.hsn)
        cnt += 1
      end
    end
    puts "Backfilled \\#{cnt} line_items"
  end
end
