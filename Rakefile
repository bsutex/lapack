
require 'fileutils'

INSTALL_DIR = '/opt/lapack'
SRC = 'src/**'
MAIN = 'lapack.rb'
EXEC = 'lapack'

task :install do |t|
  raise "You need to bee superuser" unless Process.uid == 0
  puts "Copying files to #{INSTALL_DIR}\n" + (Dir[SRCS].map{|s| "\t* #{s}"}.join("\n"))
  FileUtils.mkdir_p(INSTALL_DIR)
  FileUtils.cp(Dir[SRCS], INSTALL_DIR)
  FileUtils.ln_s(File.join(INSTALL_DIR, MAIN), File.join(INSTALL_DIR, EXEC), force: true)
  FileUtils.chmod('+x', File.join(INSTALL_DIR, MAIN))
  FileUtils.ln_s(File.join(INSTALL_DIR, EXEC), '/usr/local/bin/', force: true)
end
