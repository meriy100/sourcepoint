class SubmissionCreate
  attr_accessor :submission

  def initialize(submission)
    self.submission = submission
  end

  def run
    encoding_code = EncodingCode.new(@submission.file1)
    encode = encoding_code.encode
    nearest_attempts = Attempt.where(current_assignment_id: @submission.assignment_id).where.not(user_id: @submission.user_id).sort_by { |attempt|
      dist = Levenshtein.normalized_distance(encode, attempt.encode_code)
      attempt.dist = dist
    }
    Rails.logger.info nearest_attempts.first.dist
    if run?(nearest_attempts)
      nearest_attempt_encoding = EncodingCode.new(nearest_attempts.first.file1)
      puts encoding_code.dictionary.valiable_list

      puts nearest_attempts.first.encode_code
      # line_lists = encoding_code.dictionary.valiable_order_changes.map do |dic|
      dic = encoding_code.dictionary
      puts "1"
      e =  EncodingCode.new(@submission.file1, dic).encode
      puts e
      diffs = Diff::LCS.sdiff(nearest_attempts.first.encode_code, e)

      line_list =  diffs_to_line_diffs2(diffs, encoding_code, nearest_attempt_encoding).compact.uniq

      line_list.each do |line_attributes|
        @submission.lines.create!(line_attributes.merge(attempt_id: nearest_attempts.first.id))
      end
      @submission
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
        case before.nil? ? :all : three_different(encoding_code.charlist[before.new_position].first, encoding_code.charlist[diff.new_position].first, encoding_code.charlist[minuses.last.new_position].first)
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
  # rescue NoMethodError => e
  #   puts e
  #   puts "NoMethodError : submission_id: #{submission.id}, template_id: #{submission.template_id}"
  #   []
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



  def run?(nearest_attempts)
    (nearest_attempts.first&.dist || 1.0) < 0.3
  end

end
