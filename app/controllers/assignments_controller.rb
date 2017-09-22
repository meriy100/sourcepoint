class AssignmentsController < ApplicationController
  def show
    @submissions = Submission.where(assignment_id: params[:id]).page(params[:page] || 0).includes(:lines)
  end
end
