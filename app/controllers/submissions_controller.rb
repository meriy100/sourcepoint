class SubmissionsController < ApplicationController
  def show
    find_submission
  end

  def new
    @submission = Submission.new(submitted: Time.zone.now)
  end

  def create
    @submission = Submission.new(submission_params)
    if @submission.save
      redirect_to @submission
    else
      render :new
    end
  end

  private

  def submission_params
    params.require(:submission).permit(
      :submitted, :file1, :messages, :status, :mark, :comment, :assignment_id, :user_id
    )
  end

  def find_submission
    @submission ||= Submission.find(params[:id])
  end
end
