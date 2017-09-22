class ChecksController < ApplicationController
  def create
    find_submission.build_check(check_params).save!
    redirect_to submission_path(find_submission)
  end

  def update
    find_submission.check.update!(check_params)
    redirect_to submission_path(find_submission)
  end

  private

  def check_params
    params.require(:check).permit(
      :valiable_order,
      :blacket,
      :success,
      :near,
      :complete,
      :remarks
    )
  end

  def find_submission
    @submission ||= Submission.find(params[:submission_id])
  end

  def find_check
    @check ||= find_submission.check
  end
end
