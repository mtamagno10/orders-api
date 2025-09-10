require 'httparty'

class CustomerApiClient
  include HTTParty
  base_uri 'http://localhost:3001'

  def get_customer(id)
    response = self.class.get("/customers/#{id}")
    response.parsed_response
  end
end