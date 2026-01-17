require 'minitest/autorun'
require 'rack/test'
require_relative '../../app/controllers/inventory_items_controller'

class InventoryItemsControllerTest < Minitest::Test
  include Rack::Test::Methods
  def app; Proc.new { |env| [200, {'Content-Type' => 'text/html'}, ['OK']] }; end
  def test_index
    get '/inventory_items'
    assert last_response.ok?
  end
end
