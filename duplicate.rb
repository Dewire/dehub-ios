
require 'FileUtils'

if ARGV.empty? || ARGV.first =~ /-?-?help/i
  puts "Usage: duplicate.rb DESTINATION_PATH"
  exit
end

EXCLUDES = %w[. .. .git .DS_Store Carthage duplicate.rb]
paths = Dir.glob("*", File::FNM_DOTMATCH) - EXCLUDES

name = ARGV.first
dest = File.absolute_path(ARGV.last)

unless File.directory?(dest)
  FileUtils.mkdir_p(dest)
end

FileUtils.cp_r(paths, dest)

puts "copy ok"
puts "open the copied project in Xcode and follow these steps to rename:\n" +
     "http://matthewfecher.com/app-developement/xcode-tips-the-best-way-to-change-a-project-name-in-xcode/"

