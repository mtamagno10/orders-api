class OrdersController < ApplicationController
    def create
        customer_service = CustomerService.new
        order_service = OrderCreationService.new

        customer_details = customer_service.fetch_customer(order_params[:customer_id])

        if customer_details[:error]
            render json: { error: customer_details[:error] }, status: :not_found
            return
        end

        result = order_service.create_order(order_params, customer_details)
        if result[:success]
            render json: { order: result[:order], customer: customer_details }, status: :created
        else
            render json: { errors: result[:errors] }, status: :unprocessable_content
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