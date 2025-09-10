require 'bunny'

class OrderEventPublisher
  def self.publish_order_created(order)
    connection = Bunny.new 
    connection.start
    channel = connection.create_channel

    exchange = channel.direct('orders_events')

    payload = {
      event: "OrderCreated",
      customer_id: order.customer_id,
      order_id: order.id
    }.to_json

    exchange.publish(payload, routing_key: 'order.created')
    
    connection.close
  end
end