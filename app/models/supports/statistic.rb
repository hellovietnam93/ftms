class Supports::Statistic
  def initialize args = {}
    @locations = args[:locations]
  end

  def trainee_types
    @trainee_types ||= if @locations.nil?
      UserType.includes(:profiles).collect{|u| Hash[:name, u.name, :y, u.profiles.size]}
        .delete_if{|p| p[:y] == 0}.sort_by{|u| u[:y]}.reverse
    else
      temp = []
      @locations.each do |location|
        temp += location.profiles.collect{|p| p.user_type_name}.delete_if{|p| p.nil?}
      end
      temp.inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}.
        to_a.collect {|e| Hash[:name, e.first, :y, e.last]}.sort_by{|u| u[:y]}.reverse
    end
  end

  def locations
    @trainee_locations ||= Hash[Location.includes(:profiles).collect{|p| [p.name, p.profiles.size]}]
  end
end
