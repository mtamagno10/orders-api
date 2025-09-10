require 'rails_helper'
require 'webmock/rspec'

RSpec.describe CustomerApiClient do
  describe "#get_customer" do
    it "returns customer data when the API responds with 200" do
      stub_request(:get, "http://localhost:3001/customers/3")
        .to_return(
          status: 200,
          body: {
            customer_name: "Matilda Gomez",
            address: "854 San Martin Ave",
            orders_count: 1
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      client = CustomerApiClient.new
      result = client.get_customer(3)

      expect(result["customer_name"]).to eq("Matilda Gomez")
      expect(result["address"]).to eq("854 San Martin Ave")
      expect(result["orders_count"]).to eq(1)
    end

    it "returns an error when the customer does not exist" do
      stub_request(:get, "http://localhost:3001/customers/9999")
        .to_return(
          status: 404,
          body: { error: "Customer not found" }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      client = CustomerApiClient.new
      result = client.get_customer(9999)

      expect(result["error"]).to eq("Customer not found")
    end
  end
end