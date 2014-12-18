
require 'fileutils'

task :install do |t|
  raise "You need to bee superuser" unless Process.uid == 0
  puts "Copying files to /opt/lapack/\n" + (Dir['src/**'].map{|s| "\t* #{s}"}.join("\n"))
  FileUtils.mkdir_p("/opt/lapack")
  FileUtils.cp(Dir['src/**'], '/opt/lapack')
  FileUtils.ln_s('/opt/lapack/lapack.rb', '/opt/lapack/lapack', force: true)
  FileUtils.chmod('+x', '/opt/lapack/lapack.rb')
  FileUtils.ln_s('/opt/lapack/lapack', '/usr/local/bin/', force: true)
end
