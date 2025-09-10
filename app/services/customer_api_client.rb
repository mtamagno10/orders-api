require 'httparty'

class CustomerApiClient
  include HTTParty
  base_uri ENV.fetch('CUSTOMER_API_URL')

  def get_customer(id)
    response = self.class.get("/customers/#{id}")
    response.parsed_response
  end
end