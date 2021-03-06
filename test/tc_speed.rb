# Tests adapted from faster_csv:
# https://github.com/JEG2/faster_csv/blob/master/test/tc_speed.rb
# See LICENSE file for full license details.

require 'minitest/autorun'
require 'minitest/benchmark'
require 'fastest_csv'
require 'timeout'
require 'csv'

class TestCSVSpeed < Minitest::Test

  PATH = File.join(File.dirname(__FILE__), "test_data_speed.csv")

  def test_that_we_are_doing_the_same_work
    FastestCSV.open(PATH) do |fcsv|
      CSV.foreach(PATH) do |csv_row|
        fastest_row = fcsv.shift
        assert_equal(csv_row, fastest_row)

        # FastestCSV does not quote empty elements, need to do this to force CSV to do the same
        nilled_row = fastest_row.map { |x| x == '' ? nil : x }
        assert_equal(CSV.generate_line(nilled_row),
                     FastestCSV.generate_line(fastest_row))
      end
    end
  end

  def test_read_and_parse_speed_vs_csv
    csv_time = Time.now
    CSV.foreach(PATH) do |_row|
      # do nothing, we're just timing a read...
    end
    csv_time = Time.now - csv_time

    fastest_csv_time = Time.now
    FastestCSV.foreach(PATH) do |_row|
      # do nothing, we're just timing a read...
    end
    fastest_csv_time = Time.now - fastest_csv_time

    puts
    puts "CSV read and parse: #{csv_time}"
    puts "FastestCSV read and parse: #{fastest_csv_time}"
    puts

    assert(fastest_csv_time < csv_time)
  end

  def test_generate_speed_vs_csv
    csv_data = []
    fastest_csv_data = []

    CSV.foreach(PATH) do |row|
      csv_data << row.map { |x| x == '' ? nil : x } # don't include this conversion in the timing
      fastest_csv_data << row
    end

    csv_time = Time.now
    csv_data.each do |row|
      CSV.generate_line(row)
    end
    csv_time = Time.now - csv_time

    fastest_csv_time = Time.now
    fastest_csv_data.each do |row|
      FastestCSV.generate_line(row)
    end
    fastest_csv_time = Time.now - fastest_csv_time

    puts
    puts "CSV generate: #{csv_time}"
    puts "FastestCSV generate (generate_line): #{fastest_csv_time}"
    puts

    assert(fastest_csv_time < csv_time / 3)
  end

end
