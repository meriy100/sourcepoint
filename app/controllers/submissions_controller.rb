class SubmissionsController < ApplicationController
  def show
    @line_numbers = find_submission.lines
    encoding_code = EncodingCode.new(@submission.file1, @submission.assignment_id)
    if attempt = @line_numbers.first&.attempt.presence
      @dist = Levenshtein.normalized_distance(encoding_code.encode, attempt.encode_code)
    else
      @dist = 0
    end
  end

  def new
    @submission = Submission.new()
  end

  def create
    if request.remote_ip == "133.2.210.1"
      render text: 200 and return
    end

    @submission = if params[:submission].blank?
      Submission.new(submission_params)
    else
      Submission.new(params.require(:submission).permit(:file1, :messages, :status, :mark, :comment, :assignment_id, :user_id))
    end
    if @submission.save!
      SubmissionCreate.new(@submission).run
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

  def three_different(one, two, three)
    if one == three
      :no
    elsif one == two
      :bottom
    elsif two == three
      :top
    else
      :all
    end
  end

  def minus_check(diffs)
    diff = diffs.shift
    return [] if diff.nil? # TODO : check
    if diff.action == '-'
      [diff].concat(minus_check(diffs))
    else
      [diff]
    end
  end

  def diffs_to_line_diffs2(diffs, encoding_code, expect_code, before = nil)
    expect_code.encode if before.nil?

    diff = diffs.shift
    return [] if diff.nil?
    case diff.action
    when '='
      [].concat(diffs_to_line_diffs2(diffs, encoding_code, expect_code, diff))
    when '+', '!'
      [{ number: encoding_code.charlist[diff.new_position].first }].concat(diffs_to_line_diffs2(diffs, encoding_code, expect_code, diff))
    when '-'
      minuses = minus_check(diffs)
      diffs.unshift minuses.pop
      if minuses.blank?
        [{ number: encoding_code.charlist[diff.new_position].first}].concat(diffs_to_line_diffs2(diffs, encoding_code, expect_code, diff))
      else
        case three_different(encoding_code.charlist[before.new_position].first, encoding_code.charlist[diff.new_position].first, encoding_code.charlist[minuses.last.new_position].first)
        when :top
          case three_different(expect_code.charlist[before.old_position].first, expect_code.charlist[diff.old_position].first, expect_code.charlist[minuses.last.old_position].first)
          when :top
            [{ number: encoding_code.charlist[diff.new_position].first}].concat(diffs_to_line_diffs2(diffs, encoding_code, expect_code, diff))
          when :no
            [{ number: encoding_code.charlist[minuses.last.new_position].first, deleted_line: true }].concat(diffs_to_line_diffs2(diffs, encoding_code, expect_code, diff))
          when :all
            [{ number: encoding_code.charlist[diff.new_position].first, deleted_line: true }].concat(diffs_to_line_diffs2(diffs, encoding_code, expect_code, diff))
          when :bottom
            [{ number: encoding_code.charlist[before.new_position].first}].concat(diffs_to_line_diffs2(diffs, encoding_code, expect_code, diff))
          end
        when :all
          [{ number: encoding_code.charlist[diff.new_position].first}].concat(diffs_to_line_diffs2(diffs, encoding_code, expect_code, diff))
        when :bottom
          case three_different(expect_code.charlist[before.old_position].first, expect_code.charlist[diff.old_position].first, expect_code.charlist[minuses.last.old_position].first)
          when :top, :no
            [{ number: encoding_code.charlist[diff.new_position].first}].concat(diffs_to_line_diffs2(diffs, encoding_code, expect_code, diff))
          when :all
            [{ number: encoding_code.charlist[minuses.last.new_position].first, deleted_line: true }].concat(diffs_to_line_diffs2(diffs, encoding_code, expect_code, diff))
          when :bottom
            [{ number: encoding_code.charlist[minuses.last.new_position].first}].concat(diffs_to_line_diffs2(diffs, encoding_code, expect_code, diff))
        end
        when :no
          case three_different(expect_code.charlist[before.old_position].first, expect_code.charlist[diff.old_position].first, expect_code.charlist[minuses.last.old_position].first)
          when :all, :no, :top
            [{ number: encoding_code.charlist[diff.new_position].first}].concat(diffs_to_line_diffs2(diffs, encoding_code, expect_code, diff))
          when :bottom
            [{ number: encoding_code.charlist[minuses.last.new_position].first + 1, deleted_line: true }].concat(diffs_to_line_diffs2(diffs, encoding_code, expect_code, diff))
          end
        end
      end
    else
      raise StandardError.new('要確認')
    end
  end

  def diffs_to_line_diffs(diffs, encoding_code, expect_encode)
    expect_encode.encode
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
    params.permit(:file1, :messages, :status, :mark, :comment, :assignment_id, :user_id, :template_id)
  end

  def find_submission
    @submission ||= Submission.find(params[:id])
  end

  def run?(nearest_attempts)
    (nearest_attempts.first&.dist || 1.0) < 0.5
  end
end
