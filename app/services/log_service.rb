class LogService
  attr_accessor :current_time, :logfile

  def initialize current_time
    @current_time = current_time
    dir = File.dirname("#{Rails.root}/log/imports/#{@current_time}.log")

    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    @logfile ||= Logger.new("#{Rails.root}/log/imports/#{@current_time}.log")
  end

  def write_success_log model_attributes
    write_info "#{model_attributes[:content]} was imported successfully"
  end

  def write_fails_log model_attributes
    write_error "#{model_attributes[:content]} was imported fail"
  end

  def write_total_number_log numbers_success, numbers_fails
    write_total "#{numbers_success} records was imported, #{numbers_fails} records counldn't import"
  end

  ["info", "error", "total"].each do |type|
    define_method "write_#{type}" do |content|
      @logfile.send type, content
    end
  end

  # def write_info content
  #   @logfile.info content
  # end

  # def write_error content
  #   @logfile.error content
  # end

  # def write_total content
  #   @logfile.fatal content
  # end
end
