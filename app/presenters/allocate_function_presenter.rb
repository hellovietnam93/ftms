class AllocateFunctionPresenter < ActionView::Base
  include Rails.application.routes.url_helpers

  def initialize args
    @routes_admin = args[:routes_admin]
    @routes_trainer = args[:routes_trainer]
    @routes_trainee = args[:routes_trainee]
    @namespace = args[:namespace]
    @role = args[:role]
    @form = args[:form]
  end

  def render
    sidebar_admin = Array.new
    sidebar_trainer = Array.new
    sidebar_trainee = Array.new
    body_admin = Array.new
    body_trainer = Array.new
    body_trainee = Array.new
    @routes_admin.each_with_index do |route, index|
      sidebar_admin << sidebar_item(route, index)
      body_admin << body_item(route, index)
    end
    @routes_trainer.each_with_index do |route, index|
      sidebar_trainer << sidebar_item(route, index)
      body_trainer << body_item(route, index)
    end
    @routes_trainee.each_with_index do |route, index|
      sidebar_trainee << sidebar_item(route, index)
      body_trainee << body_item(route, index)
    end
    html = "<aside id=\"parent\" class=\"fixedTable-sidebar\">
      <div id=\"child\">
        <div id=\"table-sidebar\">
          <div class=\"tbody listsort filter_table_left_part\" id=\"list-records\">
    "
    html += "<div class=\"route_admin\">"
    html += sidebar_admin.join("")
    html += "</div>"
    html += "<div class=\"route_trainer\">"
    html += sidebar_trainer.join("")
    html += "</div>"
    html += "<div class=\"route_trainee\">"
    html += sidebar_trainee.join("")
    html += "</div>"
    html += "</div></div></div></aside>"

    html += "<div class=\"fixedTable-body tabel-scroll\">
      <div class=\"tbody listsort filter_table_right_part\">"
    html += "<div class=\"route_admin\">"
    html += body_admin.join("")
    html += "</div>"
    html += "<div class=\"route_trainer\">"
    html += body_trainer.join("")
    html += "</div>"
    html += "<div class=\"route_trainee\">"
    html += body_trainee.join("")
    html += "</div>"
    html += "</div></div>"
  end

  private
  def sidebar_item route, index
    "<div class=\"trow list_#{index}\" id=\"sidebar-row-#{route[:controller]}\" class=\"#{route[:controller].split("/").first}\">
      <div class=\"tcell stt\">#</div>
      <div class=\"tcell name controller_name\" title=\"#{route[:controller]}\">
        #{route[:controller]}
      </div>
    </div>
    "
  end

  def body_item route, index
    html = "<div class=\"trow #{"list_#{index}" }\"
      id=\"body-row-#{route[:controller]}\">"
    Settings.functions.each do |function|
      if route[:actions].include? function
        @form.fields_for :functions, @role.functions.build do |builder|
          html += "#{builder.hidden_field :id, value: find_function(function, route[:controller])}
          #{builder.hidden_field :model_class, value: route[:controller]}
          #{builder.hidden_field :action, value: function}
          <div class=\"tcell #{function}-function text-center\" title=\"#{function}\">
            #{builder.check_box :_destroy, {checked: find_function(function, route[:controller]).present?}, false, true}
          </div>"
        end
      else
        html += "<div class=\"tcell #{function}-function text-center\"
          title=\"#{function}\"></div>"
      end
    end
    html += "<div class=\"tcell text-center\">
      <input type=\"checkbox\" data-parent=\"#{index}\" class=\"sltAll\"></input></div>
    </div>"
  end

  def find_function action, model_class
    function = @role.functions.find {|function| function.action == action && function.model_class == model_class}
    function.present? ? function.id : nil
  end
end
