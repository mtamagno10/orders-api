require 'rails_helper'

RSpec.describe OrderEventPublisher do
  describe ".publish_order_created" do
    let(:order) { double("Order", customer_id: 42, id: 123) }

    it "publishes the order created event with correct payload and routing key" do
      channel = double("Channel")
      exchange = double("Exchange")

      bunny_connection = double("Bunny", start: true, create_channel: channel, close: true)
      allow(Bunny).to receive(:new).and_return(bunny_connection)
      allow(channel).to receive(:direct).with('orders_events').and_return(exchange)
      allow(exchange).to receive(:publish)

      described_class.publish_order_created(order)

      payload = {
        event: "OrderCreated",
        customer_id: 42,
        order_id: 123
      }.to_json

      expect(exchange).to have_received(:publish).with(payload, routing_key: 'order.created')
      expect(bunny_connection).to have_received(:start)
      expect(bunny_connection).to have_received(:close)
    end
  end
end