class AdminsController < ApplicationController
  def show

  end
  def access_report
    @applications = UserApplication.all
  end
end
