class Admin::ImportsController < ApplicationController
  load_and_authorize_resource

  def index
    if params[:time]
      if @filename = Dir["#{Rails.root}/log/imports/#{params[:time]}.log"].first
        @file = File.open(@filename)
      else
        redirect_to imports_path, alert: flash_message("import.no_log")
      end
    end
  end

  def create
    if params[:type].present?
      @current_time = Time.now.strftime t("datetime.formats.time_log")
      @logfile = LogService.new @current_time

      params[:type].each_with_index do |data_type, index|
        import = ImportService.new params[:file][index].tempfile.path.to_s,
          find_model(data_type).constantize, find_verify_attribute(data_type), data_type, @logfile
        if import.valid?
          import.save
        else
          @logfile.write_error "#{data_type.gsub("_", " ").capitalize.pluralize} was imported fail"
        end
      end

      redirect_to admin_imports_path time: @current_time
    else
      redirect_to admin_imports_path, alert: flash_message("import.no_select_file")
    end
  end

  private
  def find_model data_type
    data_type.split("_").each {|word| word.capitalize!}.join("")
  end

  def find_verify_attribute model
    Settings.import.data_types.detect{|data_type| data_type.model == model}
      .verify_attribute.to_sym
  end
end
