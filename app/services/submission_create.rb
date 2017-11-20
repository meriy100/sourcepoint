class SubmissionCreate
  class Diffs < Array
    attr_accessor :actual, :expect
    def self.generate(actual, expect)
      Diffs.new(Diff::LCS.sdiff(expect.encode, actual.encode)).tap do |diffs|
        diffs.actual = actual
        diffs.expect = expect
      end
    end

    def block_split(stacks=[], block=[])
      diff = self.first
      return stacks if diff.nil?
      case diff.action
      when '='
        self[1..-1].diff_block_split(stacks.push(block))
      else
        self[1..-1].diff_block_split(stacks, block.push(diff))
      end
    end

    def blacket_is_none_change!
      self.collect! do |diff|
        case diff.action
        when '+'
          if ['{', '}', ' '].include?(diff.new_element)
             Diff::LCS::ContextChange.new("=", diff.old_position, diff.old_element, diff.new_position, diff.new_element)
          else
           diff
          end
        when '-'
          if ['{', '}', ' '].include?(diff.old_element)
            diff = Diff::LCS::ContextChange.new("=", diff.old_position, diff.old_element, diff.new_position, diff.new_element)
          else
            diff
          end
        else
          diff
        end
      end
    end


    def foo
       self.reject(&:unchanged?).map do |diff|
        {
          actual: actual.charlist[diff.new_position],
          expect: expect.charlist[diff.old_position]
        }
      end
    end

    def to_s
      self.map do |diff|
        case diff.action
        when '='
          diff.new_element
        when '+'
          if ['{','}'].include?(diff.new_element)
            diff.new_element
          else
            "\e[32m#{diff.new_element}\e[0m"
          end
        when '-'
          if ['{','}'].include?(diff.old_element)
            diff.old_element
          else
            "\e[31m#{diff.old_element}\e[0m"
          end
        when '!'
          "\e[33m#{diff.new_element}\e[0m"
        end
      end
      .join
    end

    def number_split
      self.with_number.collection_map { |first, second|
        first.actual_number == second.actual_number
      }.map { |eb|
        eb.collection_map { |first, second|
         first.expect_number == second.expect_number
       }
     }
    end

    def with_number
      self.map do |diff|
        DiffWithNumber.new(diff, actual, expect)
      end
    end

    def split_block(block, stack = [])
      b = block.shift
      if b.action == '='
        stack.push(b)
        split_block(bloc, stack)
      elsif b.actual_element.nil?
        if nb = block.find { |nb| nb.actual_element.present? }.presence
          b.expect_element == nb.actual_element
        else
        end
      else
      end
    end

    def to_lines
      number_split.map do |actual_split|
        next if actual_split.flatten.all?(&:unchanged?)
        if actual_split.length > 1
          block =  actual_split.flatten
        else
          actual_split.flatten.map(&:actual_number)
        end
      end
    end
  end

  class DiffWithNumber
    attr_accessor :diff, :actual_number, :expect_number
    def initialize(diff, actual, expect)
      self.diff = diff
      self.actual_number = actual.charlist[diff.new_position].number
      self.expect_number = expect.charlist[diff.old_position].number
    end
    delegate :action, :new_element, :old_element, :unchanged?, to: :diff
    alias :actual_element :new_element
    alias :expect_element :old_element
  end

  attr_accessor :submission, :assignment_id

  def initialize(submission)
    self.submission = submission
    self.assignment_id = submission.assignment_id
  end

  def actual
    @actual ||= EncodingCode.new(@submission.file1, assignment_id).tap(&:encode)
  end

  def expect
    @expect ||= EncodingCode.new(nearest_attempts.first.file1, assignment_id)
  end

  def diffs
    @diffs ||= Diffs.generate(actual, expect)
  end

  def nearest_attempts
    @nearest_attempts ||= Attempt.where(current_assignment_id: @submission.assignment_id).where.not(user_id: @submission.user_id).sort_by { |attempt|
      dist = Levenshtein.normalized_distance(actual.encode, attempt.encode_code)
      attempt.dist = dist
    }
  end

  def run
    Rails.logger.info nearest_attempts.first.dist
    if run?(nearest_attempts)
      puts actual.dictionary.valiable_list
      puts "\e[32m#{actual.encode}\e[0m"
      puts "\e[31m#{expect.encode}\e[0m"
      # line_lists = encoding_code.dictionary.valiable_order_changes.map do |dic|
      # encoding_code =  EncodingCode.new(@submission.file1, assignment_id, dic)
      diffs.blacket_is_none_change!
      puts diffs.to_s

      line_list = diffs_to_line_diffs2(diffs.dup, actual, expect).compact.uniq

      #############
      unless ENV['NOSPLIT'] == '1'
        f = diffs.foo
        # TODO : ここで 定義とその他で分割(それ以外のロジックブロックで分けたいときも)
        b = bar(f.select { |ff| actual.decl_lines.include?(ff[:actual].number) })
          .concat(bar(f.reject { |ff| actual.decl_lines.include?(ff[:actual].number) }))

        rh = RpcsHTTPS.new(ENV['RPCSR_PASSWORD'])
        b.each do |numbers|
          next if numbers.blank?
          e = exchange_encode(expect, actual, numbers).collection_map { |first, last|
            first.number == last.number
          }.map{|sets| sets.map(&:last).join}.join("\n")

          Tempfile.open do |tmp|
            recode = expect.headers_str.concat(expect.recode(e)).encode('UTF-8', 'UTF-8').concat("\n")
            File.write tmp, recode
            res = rh.create_attempt(tmp.path, assignment_id == 441 ? 587: assignment_id)
            if res['location'].present?
              m = res['location'].match(%r{/(?<id>\d+)\z})
              status = rh.get_attempt_status(m[:id])
              puts status
              if status == 'checked'
                line_list.reject! { |line| numbers.map{|n| n[:actual].number * -1}.include?(line[:number]) } # TODO : 要検証
                attempt = nearest_attempts.first.dup
                # Tempfile.open do |tmp_reindent|
                #   Open3.capture3('indent', tmp.path, tmp_reindent.path)
                #   attempt.file1 = File.read(tmp_reindent.path)
                # end
                attempt.file1 = recode
                puts recode
                attempt.encode_code = EncodingCode.new(attempt.file1, assignment_id).encode
                attempt.save!
              end
            else
              raise
            end
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

  def bar(blocks)
    blocks.sort_by{|b|b[:expect].number}.collection_map { |first, second| first[:expect].number.between?(second[:expect].number-1, second[:expect].number) }
  end

  def exchange_encode(target, other, numbers)
    result = []
    before = target.charlist.select{|charset| charset.number < numbers.first[:expect].number}
    middle = other.charlist.select{|charset| numbers.map{|n|n[:actual].number}.include?(charset.number)}.each{|charset|charset.number *= -1}
    after = target.charlist.select{|charset| charset.number > numbers.last[:expect].number}
    result.concat(before).concat(middle).concat(after)
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
