require './data'
require './pre_data'

class Array
  def average
    total = 0.0
    self.each do |item|
      total += item
    end
    total / self.size
  end
end

def diff_times(created_ats)
  created_ats.sort!
  created_ats.map.with_index(0) do |created_at, idx|
    next if idx.zero?
    created_at - created_ats[idx - 1]
  end
  .compact
end

def molding(datas)
  datah = {}
  datas.each { |u, c| datah.key?(u) ? datah[u].push(c) : datah[u]  = [c] }
  datah
end

def diff_and_ave(datas)
  data1h = molding(datas.sort_by{|u,_|u}.map { |u, c| [u, Time.zone.parse(c)] })
  averages1 =  data1h.map do |u, cs|
    diff_times(cs).average
  end
  time1 = data1h.map { |u, cs| diff_times [cs.first, cs.last] }
end


def all_diff_clear_to_frist(assignemnts)
  clear_times = assignemnts.flat_map do |assignemnt|
    print "#"
    assignemnt.attempts.group_by(&:user_id).values.map do |attempts|
      next unless attempts.any? { |a| a.status == "checked" }
      attempts.sort_by!(&:created_at)
      # next unless attempts.last.created_at.wday == 4
      attempts.last.created_at - attempts.first.created_at
    end
    .compact
  end
end

def minute_count(clear_times)
  minute_count = {}
  clear_times.each do |time|
    minute = (time / 60).floor
    minute_count[minute] = [0] unless minute_count.key?(minute)
    minute_count[minute][0] += 1
    minute_count[minute].push(time)
  end
  minute_count
end

def martin_data_clear_time(martin_data)
  martin_data.group_by{|h| h[:user]}.values.map do |attempts|
    next unless attempts.any? { |a| a[:status] == "checked" }
    attempts.sort_by!{|a| a[:time]}
    # next unless attempts.last[:time].since(9.hours).wday == 4
    attempts.last[:time] - attempts.first[:time]
  end
  .compact
end

def main
  target_assignment_ids = [466, 392, 320]
  # clear_times = all_diff_clear_to_frist(Assignment.where.not(id: target_assignment_ids).sample(100))
  clear_times = all_diff_clear_to_frist(Assignment.where(id: [36, 106, 177, 247, 319, 391, 465]))
  puts "size #{clear_times.count}"
  puts clear_times.average
  puts clear_times[clear_times.length/2]
  File.open("data1.csv", "w") do |f|
    clear_times.each do |time|
      f.puts time
    end
  end
  File.open("data2.csv", "w") do |f|
    minute_count(clear_times).each do |time, count_and_times|
      f.puts "#{time}, #{count_and_times.join(", ")}"
    end
  end

  target_assignment_ids = [466, 392, 320]
  clear_times = all_diff_clear_to_frist(Assignment.where(id: target_assignment_ids).sample(100))
  puts "size #{clear_times.count}"
  puts clear_times.average
  puts clear_times[clear_times.length/2]
  File.open("data3.csv", "w") do |f|
    clear_times.each do |time|
      f.puts time
    end
  end
  File.open("data4.csv", "w") do |f|
    minute_count(clear_times).each do |time, count_and_times|
       f.puts "#{time}, #{count_and_times.join(", ")}"
    end
  end

  data_09other = []
  data_09B1 = []
  pre_data.map do |hash|
    hash[:time] = Time.zone.parse(hash[:time])
    hash
  end
    .each do |hash|
      case hash[:code]
      when '09B1'
        data_09B1.push  hash
      else
        data_09other.push hash
      end
    end

  clear_times = martin_data_clear_time(data_09other)
  puts "09other"
  puts "size #{clear_times.count}"
  puts clear_times.average
  puts clear_times[clear_times.length/2]
  clear_times = martin_data_clear_time(data_09B1)
  puts "09B1"
  puts "size #{clear_times.count}"
  puts clear_times.average
  puts clear_times[clear_times.length/2]
end

if __FILE__ == $0
  main
end
