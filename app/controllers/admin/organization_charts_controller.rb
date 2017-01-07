class Admin::OrganizationChartsController < ApplicationController
  before_action :authorize

  def index
    @locations = Location.includes :manager,
      profiles: [:trainee_type, user: [user_subjects: [course_subject: :subject]]]
    @support = Supports::OrganizationSupport.new
    add_breadcrumb_index "organization_charts"
  end
end
