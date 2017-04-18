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
      encoding_code = EncodingCode.new(@submission.file1)
      encode = encoding_code.encode
      nearest_attempts = Attempt.where(current_assignment_id: @submission.assignment_id).map { |attempt|
        [attempt, Levenshtein.normalized_distance(encode, attempt.encode_code)]
      }.sort_by { |_, weight| weight }

      diffs = Diff::LCS.sdiff(nearest_attempts.first.first.encode_code, encode)
      line_list = diffs.map { |context_change|
        case context_change.action
        when '='
        when '-'
          encoding_code.charlist[context_change.new_position].first
        when '+'
          encoding_code.charlist[context_change.new_position].first
        when '!'
          encoding_code.charlist[context_change.new_position].first
        else
        end
      }.compact.uniq

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
