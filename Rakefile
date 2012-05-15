require 'fileutils'
require 'json'

#
# Config
#

#
# Rake Tasks
#

task :default => :help

task :help do
  puts "\n"
  system "rake -T"
end

desc "Install all required files."
task :install do
  puts "Starting installation …"
  
  commands = [
    "sudo gem update --system",
    "sudo gem install bundler",
    "bundle install"
  ]
  
  system commands.join(";")
  
  puts "Installation successful!"
end

desc "Build Public HTML"
task :build do
  system "middleman build"
end

desc "Run local development server"
task :server do
  system "middleman server"
  system "open http://0.0.0.0:4567"
end

#
# Helpers
#