class Supports::LocationSupport
  attr_reader :location

  def initialize args
    @location = args[:location]
  end

  def manager
    @manager ||= @location.manager
  end

  def trainers
    @trainers ||= User.trainers.includes(:trainees).by_location @location.id
  end
end
