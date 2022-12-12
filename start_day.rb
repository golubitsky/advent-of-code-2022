require 'fileutils'

raise 'supply day as first arg' unless ARGV.first

day = ARGV.first

File.write(
  "day_#{day}.rb",
  File.read('ruby_template.txt').sub('DAY_NUMBER', day)
)

FileUtils.touch("data/day_#{day}.txt")
FileUtils.touch("data/day_#{day}_sample.txt")
