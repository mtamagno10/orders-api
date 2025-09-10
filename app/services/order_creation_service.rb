class OrderCreationService
  def initialize(event_publisher = OrderEventPublisher)
    @event_publisher = event_publisher
  end

  def create_order(order_params, customer_details)
    order = Order.new(order_params)
    if order.save
      @event_publisher.publish_order_created(order)
      { success: true, order: order }
    else
      { success: false, errors: order.errors.full_messages }
    end
  end
end