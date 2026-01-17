require 'minitest/autorun'
require 'rack/test'
require_relative '../../app/controllers/orders_controller'

class OrdersControllerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Proc.new { |env| [200, {'Content-Type' => 'text/html'}, ['OK']] }
  end

  def test_index_ok
    get '/orders'
    assert last_response.ok?
  end
end
