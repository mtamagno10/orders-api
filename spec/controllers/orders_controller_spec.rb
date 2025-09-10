require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
    before do
        allow_any_instance_of(CustomerApiClient).to receive(:get_customer)
            .with("3")
            .and_return({
            "customer_name" => "Matilda Gomez",
            "address" => "Av. San Martín 854",
            "orders_count" => 1
            })

        allow_any_instance_of(CustomerApiClient).to receive(:get_customer)
            .with("9999")
            .and_return({ "error" => "Customer not found" })

        allow(OrderEventPublisher).to receive(:publish_order_created)
    end    

  describe "POST #create" do
    it "creates an order and returns status 201" do
      post :create, params: {
        order: {
          customer_id: 3,
          product_name: "Samsung S25 Ultra",
          quantity: 1,
          price: 1250.0,
          status: "PENDING"
        }
      }
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["order"]["id"]).not_to be_nil
      expect(json["order"]["customer_id"]).to eq(3)
      expect(json["order"]["product_name"]).to eq("Samsung S25 Ultra")
      expect(json["customer"]["customer_name"]).to eq("Matilda Gomez")
      expect(OrderEventPublisher).to have_received(:publish_order_created)
    end

    it "returns an error if the customer does not exist" do
      post :create, params: {
        order: {
          customer_id: 9999,
          product_name: "Samsung S25 Ultra",
          quantity: 1,
          price: 1250.0,
          status: "PENDING"
        }
      }
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Customer not found")
    end

    it "does not create the order and returns an error if the parameters are invalid" do
      post :create, params: {
        order: {
          customer_id: 3,
          product_name: "",
          quantity: nil,
          price: nil,
          status: ""
        }
      }
      expect(response).to have_http_status(:unprocessable_content)
      json = JSON.parse(response.body)
      expect(json["errors"]).not_to be_empty
    end
  end

  describe "GET #index" do
    it "returns orders filtered by customer_id" do
      order = Order.create!(
        customer_id: 3,
        product_name: "Samsung S25 Ultra",
        quantity: 1,
        price: 1250.0,
        status: "PENDING"
      )
      get :index, params: { customer_id: 3 }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.first["id"]).to eq(order.id)
      expect(json.first["customer_id"]).to eq(3)
    end

    it "returns an error if customer_id is missing" do
      get :index
      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("customer_id is required")
    end
  end
end