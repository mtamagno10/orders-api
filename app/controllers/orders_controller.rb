    class OrdersController < ApplicationController
    def create
        customer_id = order_params[:customer_id]

        customer_details = CustomerApiClient.new.get_customer(customer_id)

        if customer_details["error"]
        render json: { error: "Customer not found" }, status: :not_found
        return
        end

        order = Order.new(order_params)
        if order.save
        OrderEventPublisher.publish_order_created(order)
        render json: { order: order, customer: customer_details }, status: :created
        else
        render json: { errors: order.errors.full_messages }, status: :unprocessable_content
        end
    end

    def index
        if params[:customer_id].present?
        orders = Order.where(customer_id: params[:customer_id])
        render json: orders
        else
        render json: { error: "customer_id is required" }, status: :bad_request
        end
    end

    private

    def order_params
        params.require(:order).permit(:customer_id, :product_name, :quantity, :price, :status)
    end
    end
