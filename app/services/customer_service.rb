class CustomerService
  def initialize(api_client = CustomerApiClient.new)
    @api_client = api_client
  end

  def fetch_customer(customer_id)
    details = @api_client.get_customer(customer_id)
    if details["error"]
      { error: "Customer not found" }
    else
      details
    end
  end
end