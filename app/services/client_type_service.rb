module Services
  class ClientTypeService < ApplicationService
    def self.base_url; "client_types" ; end

    get "/all" do
      authenticate(:admin_user)
      cts = ClientType.all
      [200, cts.map(&:attributes).to_json]
    end
    get "/last_month" do
      authenticate(:admin_user)
      cts = ClientType.from_previous_month
      [200, cts.map(&:attributes).to_json]
    end

    get "/" do
      authenticate(:admin_user)
      cts = ClientType.from_current_month
      [200, cts.map(&:attributes).to_json]
    end
  end
end
