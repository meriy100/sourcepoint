class SubmissionsController < ApplicationController
  def show
    @line_numbers = find_submission.lines
  end

  def new
    @submission = Submission.new(submitted: Time.zone.now)
  end

  def create
    @submission = Submission.new(submission_params)
    if @submission.save
      encoding_code = EncodingCode.new(@submission.file1)
      encode = encoding_code.encode
      nearest_attempts = Attempt.where(current_assignment_id: @submission.assignment_id).sort_by { |attempt|
        Levenshtein.normalized_distance(encode, attempt.encode_code)
      }

      diffs = Diff::LCS.sdiff(nearest_attempts.first.encode_code, encode)
      line_list = diffs_to_line_diffs(diffs, encoding_code).compact.uniq

      line_list = nearest_attempts[0..2].map do |nearest_attempt|
        diffs = Diff::LCS.sdiff(nearest_attempt.encode_code, encode)
        diffs_to_line_diffs(diffs, encoding_code).compact.uniq
      end
      line_list.flatten.group_by{|i| i}.reject{|k,v| v.one?}.keys.each do |line_attributes|
        @submission.lines.create!(line_attributes.merge(attempt_id: nearest_attempts.first.id))
      end
      if params[:response_type]
        @line_numbers = find_submission.lines
        render 'diffs', layout: nil
      else
        redirect_to @submission
      end
    else
      render :new
    end
  end

  private

  def diffs_to_line_diffs(diffs, encoding_code)
    diffs.map { |context_change|
      case context_change.action
      when '='
      when '+', '!'
        { number: encoding_code.charlist[context_change.new_position].first }
      when '-'
        if encoding_code.charlist[context_change.new_position] == encoding_code.charlist[context_change.new_position - 1]
          { number: encoding_code.charlist[context_change.new_position].first }
        else
          { number: encoding_code.charlist[context_change.new_position].first, deleted_line: true }
        end
      else
        raise StandardError.new('要確認')
      end
    }
  end

  def submission_params
    params.permit(:file1, :messages, :status, :mark, :comment, :assignment_id, :user_id)
  end

  def find_submission
    @submission ||= Submission.find(params[:id])
  end
end
