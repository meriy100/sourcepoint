class SubmissionCreate
  attr_accessor :submission, :assignment_id

  def initialize(submission)
    self.submission = submission
    self.assignment_id = submission.assignment_id
  end

  def run
    encoding_code = EncodingCode.new(@submission.file1, assignment_id)
    encode = encoding_code.encode
    nearest_attempts = Attempt.where(current_assignment_id: @submission.assignment_id).where.not(user_id: @submission.user_id).sort_by { |attempt|
      dist = Levenshtein.normalized_distance(encode, attempt.encode_code)
      attempt.dist = dist
    }
    Rails.logger.info nearest_attempts.first.dist
    if run?(nearest_attempts)
      nearest_attempt_encoding = EncodingCode.new(nearest_attempts.first.file1, assignment_id)
      puts encoding_code.dictionary.valiable_list
      puts "\e[31m#{nearest_attempts.first.encode_code}\e[0m"
      # line_lists = encoding_code.dictionary.valiable_order_changes.map do |dic|
      dic = encoding_code.dictionary
      puts "1"
      e =  EncodingCode.new(@submission.file1, assignment_id, dic).encode
      puts "\e[31m#{e}\e[0m"
      diffs = Diff::LCS.sdiff(nearest_attempt_encoding.encode, e)


      line_list = diffs_to_line_diffs2(diffs.dup, encoding_code, nearest_attempt_encoding).compact.uniq

      #############
      f = foo(diffs.dup, encoding_code, nearest_attempt_encoding)
      b = bar(f)

      rh = RpcsHTTPS.new(ENV['RPCSR_PASSWORD'])
      b.each do |numbers|
        e = exchange_encode(nearest_attempt_encoding, encoding_code, numbers).map(&:last).join
        # TODO : ここで チェッキングシステムチェック!!!!!!!!!

        Tempfile.open do |tmp|
          recode = nearest_attempt_encoding.headers_str.concat(nearest_attempt_encoding.recode(e)).encode('UTF-8', 'UTF-8').concat("\n")
          File.write tmp, recode
          res = rh.create_attempt(tmp.path, assignment_id == 441 ? 587: assignment_id)
          if res['location'].present?
            m = res['location'].match(%r{/(?<id>\d+)\z})
            status = rh.get_attempt_status(m[:id])
            puts status
            if status == 'checked'
              line_list.reject! { |line| numbers.map{|n| n[:actual].number}.include?(line[:number]) } # TODO : 要検証
              attempt = nearest_attempts.first.dup
              attempt.file1 = recode
              attempt.save!
            end
          else
            raise
          end
        end
      end
      #############

      line_list.each do |line_attributes|
        @submission.lines.create!(line_attributes.merge(attempt_id: nearest_attempts.first.id))
      end
      @submission
    end
  end

  def foo(diffs, actual, expect)
    diffs_list = diff_block_split(diffs.dup)
    diffs_list.flat_map do |diffs|
      diffs.map do |diff|
        {
          actual: actual.charlist[diff.new_position],
          expect: expect.charlist[diff.old_position]
        }
      end
    end
    .reject(&:empty?)
  end

  def bar(blocks)
    blocks.sort_by{|b|b[:expect].number}.collection_map { |first, second| first[:expect].number.between?(second[:expect].number-1, second[:expect].number) }
  end

  def exchange_encode(target, other, numbers)
    result = []
    before = target.charlist.select{|charset| charset.number < numbers.first[:expect].number}
    middle = other.charlist.select{|charset| numbers.map{|n|n[:actual].number}.include?(charset.number)}
    after = target.charlist.select{|charset| charset.number > numbers.last[:expect].number}
    result.concat(before).concat(middle).concat(after)
  end

  def diff_block_split(diffs, stacks=[], block=[])
    diff = diffs.shift
    return stacks if diff.nil?
    case diff.action
    when '='
      diff_block_split(diffs, stacks.push(block))
    else
      diff_block_split(diffs, stacks, block.push(diff))
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
    (nearest_attempts.first&.dist || 1.0) < 0.3 || true
  end

end
