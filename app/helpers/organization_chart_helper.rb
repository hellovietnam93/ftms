module OrganizationChartHelper
  def load_subject_by_trainee trainees
    subjects = Subject.all
    h = Hash.new
    subjects.each{|subject| h[subject.name] = Array.new}
    trainees.each do |trainee|
      if trainee.user_subjects.testing1.any?
        h[trainee.user_subjects.testing1.first.course_subject.subject_name] << trainee.id
      end
    end
    binding.pry
  end
end
