class Supports::StatisticSupport
  def initialize args = {}
    @check = args[:check]
    @location_ids = args[:location_ids] || load_locations.map(&:id)
    @check_params_location = args[:location_ids]
    @stage_ids = args[:stage_ids] || load_stages.map(&:id)
    @start_date = args[:start_date] || Date.today.beginning_of_year
    @end_date = args[:end_date] || Date.today
  end

  def check
    if @check.nil?
      false
    else
      if @check_params_location.nil?
        true
      end
    end
  end

  def load_locations
    @locations ||= Location.all
  end

  def load_stages
    @stages ||= Stage.all
  end

  def trainee_by_locations
    @trainee_by_locations ||= Hash[load_locations.collect{|l| [l.name, l.profiles.size]}]
  end

  def trainee_types
    @trainee_types ||= if check
      load_trainee_types.collect{|u| Hash[:name, u.name, :y, u.profiles.size]}.reverse.take(1)
    else
      temp = []
      load_locations.where(id: @location_ids).includes(profiles: :user_type).each do |location|
        temp += location.profiles.collect{|p| p.user_type_name}.delete_if{|p| p.nil?}
      end
      temp.inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}.
        to_a.collect {|e| Hash[:name, e.first, :y, e.last]}.sort_by{|u| u[:y]}.reverse
    end
  end

  def universities
    @universities ||= University.includes(:profiles)
      .collect{|u| Hash[:name, u.name, :y, u.profiles.size]}.sort_by {|u| u[:y]}.reverse
  end

  def programming_languages
    @programming_languages ||= load_programming_languages.includes(:profiles)
      .collect{|u| Hash[:name, u.name, :y, u.profiles.size]}.sort_by {|u| u[:y]}.reverse
  end

  def month_ranges
    months
  end

  def total_trainees_presenter
    StatisticTotalTraineePresenter.new(total_trainee_by_month).render
  end

  def trainee_in_out_by_month
    @trainee_in_out_by_month ||= trainee_in_out
  end

  private
  def total_trainee_by_month
    @statistics ||= Statistic.includes(:user_type, :programming_language)
      .where.not(total_trainee: 0).order(:month)
      .where month: months.collect{|month| month.to_date.beginning_of_month},
        location_id: @location_ids, stage_id: @stage_ids
    total_trainees = {}

    load_trainee_types.each do |user_type|
      load_programming_languages.each do |programming_language|
        total_trainees[user_type: user_type.name, language: programming_language.name] = Hash[months.collect {|item| [item, 0]}]
      end
    end

    @statistics.each do |statistic|
      if total_trainees[convert_to_hash statistic]
        total_trainees[convert_to_hash statistic][statistic.month.strftime I18n.t('datetime.formats.year_month')] += statistic.total_trainee
      end
    end

    total_trainees
  end

  def convert_to_hash statistic
    Hash[:user_type, statistic.user_type_name, :language,
      statistic.programming_language_name]
  end

  def months
    date_range = @start_date..@end_date
    date_months = date_range.map {|d| Date.new(d.year, d.month, 1) }.uniq
    date_months.map {|d| d.strftime I18n.t('datetime.formats.year_month')}
  end

  def trainee_in_out
    trainee_in = {}
    trainee_out = {}
    trainee_join_div = {}
    Profile.all.each do |profile|
      months.each do |month|
        trainee_in[month] = 0 unless trainee_in[month]
        trainee_out[month] = 0 unless trainee_out[month]
        trainee_join_div[month] = 0 unless trainee_join_div[month]
        if in_month? month, profile.start_training_date
          trainee_in[month] += 1
        elsif in_month? month, profile.leave_date
          trainee_out[month] += 1
        elsif in_month? month, profile.join_div_date
          rainee_join_div[month] += 1
        end
      end
    end
    {trainee_in: trainee_in, trainee_out: trainee_out, trainee_join_div: trainee_join_div}
  end

  def in_month? month, date
    date && date >= month.to_date.beginning_of_month &&
      date <= month.to_date.end_of_month
  end

  def load_trainee_types
    @trainee_types ||= UserType.all
  end

  def load_programming_languages
    @programming_languages ||= ProgrammingLanguage.all
  end
end
