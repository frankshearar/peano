require 'rubygems'
require 'rake'

# Uses:
# rubygems
# rake
# rantly
# shoulda

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end
