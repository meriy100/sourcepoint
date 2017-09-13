class AssignmentsController < ApplicationController
  def show
    @submissions = Submission.where(assignment_id: params[:id]).includes(:lines)
  end
end
