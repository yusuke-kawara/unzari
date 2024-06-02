class HomeController < ApplicationController
  def index
  end

  def stage
    @stage = params[:stage]
  end
end
