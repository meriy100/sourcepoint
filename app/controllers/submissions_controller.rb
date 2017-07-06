class SubmissionsController < ApplicationController
  def show
    @line_numbers = find_submission.lines
  end

  def new
    @submission = Submission.new(submitted: Time.zone.now)
  end

  def create
    @submission = if params[:submission].nil?
      Submission.new(submission_params)
    else
      Submission.new(params.require(:submission).permit(:file1, :messages, :status, :mark, :comment, :assignment_id, :user_id))
    end
    if @submission.save
      encoding_code = EncodingCode.new(@submission.file1)
      encode = encoding_code.encode
      nearest_attempts = Attempt.where(current_assignment_id: @submission.assignment_id).sort_by { |attempt|
        dist = Levenshtein.normalized_distance(encode, attempt.encode_code)
        attempt.dist = dist
      }

      if @submission.assignment_id != 0 || nearest_attempts.first.dist < 0.3
        diffs = Diff::LCS.sdiff(nearest_attempts.first.encode_code, encode)
        line_list = diffs_to_line_diffs2(diffs, encoding_code, EncodingCode.new(nearest_attempts.first.file1)).compact.uniq

        line_list.each do |line_attributes|
          @submission.lines.create!(line_attributes.merge(attempt_id: nearest_attempts.first.id))
        end
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
    params.permit(:file1, :messages, :status, :mark, :comment, :assignment_id, :user_id)
  end

  def find_submission
    @submission ||= Submission.find(params[:id])
  end
end
