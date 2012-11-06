class AdminsController < ApplicationController
  def show

  end
  def access_report
    @applications = UserApplication.all
  end
  def client_types
    @client_types = ClientType.all
  end
end
