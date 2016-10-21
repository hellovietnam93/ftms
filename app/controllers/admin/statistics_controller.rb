class Admin::StatisticsController < ApplicationController
  before_action :load_locations

  def index
    @statistics = Supports::Statistic.new
  end

  def create
    locations = Location.includes(profiles: :user_type).find params[:location_ids]
    @statistics = Supports::Statistic.new locations: locations
    respond_to do |format|
      format.js
    end
  end

  private
  def load_locations
    @locations = Location.all
  end
end
