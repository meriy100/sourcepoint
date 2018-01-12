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
             Diff::LCS::ContextChange.new('=', diff.old_position, diff.old_element, diff.new_position, diff.new_element)
          else
           diff
          end
        when '-'
          if ['{', '}', ' '].include?(diff.old_element)
            Diff::LCS::ContextChange.new('=', diff.old_position, diff.old_element, diff.new_position, diff.new_element)
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
        case diff.action
        when '+'
          {
            actual: actual.charlist[diff.new_position],
            expect: expect.charlist[diff.old_position - 1]
          }
        when '-'
          {
            actual: actual.charlist[diff.new_position - 1],
            expect: expect.charlist[diff.old_position]
          }
        else
          {
            actual: actual.charlist[diff.new_position],
            expect: expect.charlist[diff.old_position]
          }
        end
      end
    end

    def foo2
      self.reject(&:unchanged?).map do |diff|
        case diff.action
          when '+'
            {
                actual: actual.charlist[diff.new_position],
                expect: expect.charlist[diff.old_position - 1]
            }
          when '-'
            if actual.charlist[diff.new_position - 1] == actual.charlist[diff.new_position]
              {
                  actual: actual.charlist[diff.new_position],
                  expect: expect.charlist[diff.old_position]
              }
            else
              {
                  actual: actual.charlist[diff.new_position - 1],
                  deleted_line: true,
                  expect: expect.charlist[diff.old_position]
              }
            end
          else
            {
                actual: actual.charlist[diff.new_position],
                expect: expect.charlist[diff.old_position]
            }
        end
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

  class DiffsToLineDiffs2
    attr_accessor :diffs, :actual, :expect

    def initialize(diffs, actual, expect)
      self.diffs = diffs
      self.actual = actual
      self.expect = expect
    end

    def search_lines
      diffs.blacket_is_none_change!
      expect.encode
      # diffs.foo2.map { |f|
      #   if f[:deleted_line]
      #     { number: f[:actual].first + 1, deleted_line: true }
      #   else
      #     { number: f[:actual].first }
      #   end
      # }.uniq
      diffs_to_line_diffs2(diffs.dup, actual, expect ).compact.uniq
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


    def diffs_to_line_diffs2(diffs, actual, expect, before=nil)
      diff = diffs.shift
      return [] if diff.nil?
      case diff.action
        when '='
          [].concat(diffs_to_line_diffs2(diffs, actual, expect, diff))
        when '+', '!'
          [{ number: actual.charlist[diff.new_position].first }].concat(diffs_to_line_diffs2(diffs, actual, expect, diff))
        when '-'
          minuses = minus_check(diffs)
          diffs.unshift minuses.pop
          if minuses.blank?
            [{ number: actual.charlist[diff.new_position].first}].concat(diffs_to_line_diffs2(diffs, actual, expect, diff))
          else
            case before.nil? ? :all : three_different(actual.charlist[before.new_position].first, actual.charlist[diff.new_position].first, actual.charlist[minuses.last.new_position].first)
              when :top
                case three_different(expect.charlist[before.old_position].first, expect.charlist[diff.old_position].first, expect.charlist[minuses.last.old_position].first)
                  when :top
                    [{ number: actual.charlist[diff.new_position].first}].concat(diffs_to_line_diffs2(diffs, actual, expect, diff))
                  when :no
                    [{ number: actual.charlist[minuses.last.new_position].first, deleted_line: true }].concat(diffs_to_line_diffs2(diffs, actual, expect, diff))
                  when :all
                    [{ number: actual.charlist[diff.new_position].first, deleted_line: true }].concat(diffs_to_line_diffs2(diffs, actual, expect, diff))
                  when :bottom
                    [{ number: actual.charlist[before.new_position].first}].concat(diffs_to_line_diffs2(diffs, actual, expect, diff))
                end
              when :all
                [{ number: actual.charlist[diff.new_position].first}].concat(diffs_to_line_diffs2(diffs, actual, expect, diff))
              when :bottom
                case three_different(expect.charlist[before.old_position].first, expect.charlist[diff.old_position].first, expect.charlist[minuses.last.old_position].first)
                  when :top, :no
                    [{ number: actual.charlist[diff.new_position].first}].concat(diffs_to_line_diffs2(diffs, actual, expect, diff))
                  when :all
                    [{ number: actual.charlist[minuses.last.new_position].first, deleted_line: true }].concat(diffs_to_line_diffs2(diffs, actual, expect, diff))
                  when :bottom
                    [{ number: actual.charlist[minuses.last.new_position].first}].concat(diffs_to_line_diffs2(diffs, actual, expect, diff))
                end
              when :no
                case three_different(expect.charlist[before.old_position].first, expect.charlist[diff.old_position].first, expect.charlist[minuses.last.old_position].first)
                  when :all, :no, :top
                    [{ number: actual.charlist[diff.new_position].first}].concat(diffs_to_line_diffs2(diffs, actual, expect, diff))
                  when :bottom
                    [{ number: actual.charlist[minuses.last.new_position].first + 1, deleted_line: true }].concat(diffs_to_line_diffs2(diffs, actual, expect, diff))
                end
            end
          end
        else
          raise StandardError.new('要確認')
      end
    end
  end

  attr_accessor :submission, :assignment_id, :expect_attempts, :same_search, :print_output

  def initialize(submission, attempts = nil, same_search: true)
    self.same_search = same_search
    self.submission = submission
    self.assignment_id = submission.assignment_id
    self.expect_attempts = attempts || Attempt.where(current_assignment_id: @submission.assignment_id)
    self.print_output = true
  end

  def stdoutputln(str)
    puts str if print_output
  end

  def stdoutput(str)
    print str if print_output
  end

  def actual
    @actual ||= EncodingCode.new(self.submission.file1, assignment_id).tap(&:encode)
  end

  def expect
    @expect ||= EncodingCode.new(nearest_attempts.first.file1, assignment_id)
  end

  def diffs
    @diffs ||= Diffs.generate(actual, expect)
  end

  class SearchBlock
    attr_accessor :actual, :expect, :diffs, :assignment_id
    def initialize(submission, attempt, assignment_id)
      self.actual = EncodingCode.new(submission.file1, assignment_id).tap(&:encode)
      self.expect = EncodingCode.new(attempt.file1, assignment_id)
      self.diffs = Diffs.generate(actual, expect)
      self.assignment_id = assignment_id
      @attempt = attempt

      STDERR.puts actual.dictionary.valiable_list
      STDERR.puts "\e[32m#{actual.encode}\e[0m"
      STDERR.puts "\e[31m#{expect.encode}\e[0m"
      STDERR.puts diffs.to_s
    end

    def run
      line_list = DiffsToLineDiffs2.new(diffs.dup, actual, expect).search_lines
      unless ENV['NOSPLIT'] == '1'
        block_split_create_attempts(line_list)
      end
      line_list
    end


    def block_split_create_attempts(line_list)
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

        Tempfile.create('sourcepoint-') do |tmp|
          recode = expect.headers_str.concat(expect.recode(e)).encode('UTF-8', 'UTF-8').concat("\n")
          File.write tmp, recode
          res = rh.create_attempt(tmp.path, assignment_id == 441 ? 587: assignment_id)
          if res['location'].present?
            STDERR.puts res['location']
            m = res['location'].match(%r{/(?<id>\d+)\z})
            status = rh.get_attempt_status(m[:id])
            STDERR.print (status == 'checked' ? "\e[32m" : "\e[31m")
            STDERR.print status
            STDERR.puts "\e[0m"
            STDERR.puts recode
            if status == 'checked'
              line_list.select { |line| numbers.map{|n| n[:actual].number * -1}.include?(line[:number]) }.map{|l|l[:checked] = true}

              attempt = @attempt.dup
              # Tempfile.open do |tmp_reindent|
              #   Open3.capture3('indent', tmp.path, tmp_reindent.path)
              #   attempt.file1 = File.read(tmp_reindent.path)
              # end
              attempt.file1 = recode
              attempt.encode_code = EncodingCode.new(attempt.file1, assignment_id).encode
              attempt.save!
            end
          else
            raise
          end
        end
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
  end

  def nearest_attempts
    @nearest_attempts ||= expect_attempts.to_a.uniq(&:encode_code).reject { |a| a.user_id ==  self.submission.user_id }.sort_by { |attempt|
      dist = Levenshtein.normalized_distance(actual.encode, attempt.encode_code)
      attempt.dist = dist
    }.reject { |attempt| same_search ? false  : attempt.dist == 0.0 }
  end

  def pre_run(attempts_create = false)
    self.print_output = false
    line_list = DiffsToLineDiffs2.new(diffs.dup, actual, expect).search_lines
    block_split_create_attempts(line_list)
  end

  def run
    Rails.logger.info nearest_attempts.first.dist
    if run?(nearest_attempts)
      line_list = SearchBlock.new(self.submission, nearest_attempts.first, assignment_id).run
      sub_line_lists = nearest_attempts[1..2].map do |ex|
        SearchBlock.new(self.submission, ex, assignment_id).run
      end

      checked_lines = sub_line_lists.flat_map do |ll|
        ll.select { |l| l[:checked] }
      end

      line_list.reject{|l| l[:checked]}.reject{|l| checked_lines.any?{|cl| cl[:number] == l[:number]}  }.each do |line_attributes|
        @submission.lines.create!(line_attributes.merge(attempt_id: nearest_attempts.first.id))
      end
      @submission
    end
  end

  private

  def run?(nearest_attempts)
    (nearest_attempts.first&.dist || 1.0) < 0.3 || true
  end
end
