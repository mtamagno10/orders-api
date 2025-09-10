require 'rails_helper'
require 'bunny'

RSpec.describe "Orders API Integration", type: :request do
  before(:all) do
    @connection = Bunny.new
    @connection.start
    @channel = @connection.create_channel
    @exchange = @channel.direct('orders_events', durable: false)
    @queue = @channel.queue('test_order_created', durable: true)
    @queue.bind(@exchange, routing_key: 'order.created')
    @queue.purge
  end

  after(:all) do
    @queue.delete if @queue
    @channel.close if @channel
    @connection.close if @connection
  end

  describe "End-to-end order creation" do
    let(:customer_id) { 4 }

    it "creates a new order and publishes the event to RabbitMQ" do
      post "/orders", params: {
        order: {
          customer_id: customer_id,
          product_name: "iPhone 15 Pro",
          quantity: 1,
          price: 1100,
          status: "PENDING"
        }
      }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["order"]["product_name"]).to eq("iPhone 15 Pro")
      expect(json["customer"]["customer_name"]).not_to be_nil

      # Verificación de evento en RabbitMQ
      delivery_info, properties, payload = @queue.pop
      expect(payload).not_to be_nil

      event = JSON.parse(payload)
      expect(event["event"]).to eq("OrderCreated")
      expect(event["order_id"]).to eq(json["order"]["id"])
      expect(event["customer_id"]).to eq(customer_id)
    end

    it "returns an error if the REAL customer does not exist in Customers API" do
      post "/orders", params: {
        order: {
          customer_id: 99999,
          product_name: "iPhone 15 Pro",
          quantity: 1,
          price: 1100,
          status: "PENDING"
        }
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Customer not found")
    end
  end
end