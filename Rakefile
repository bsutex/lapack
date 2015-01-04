
require 'fileutils'
require 'tmpdir'

INSTALL_DIR = '/opt/lapack'
SRC = 'src/**/*'
MAIN = 'lapack.rb'
EXEC = 'lapack'

task :install do |t|
  raise "You need to bee superuser" unless Process.uid == 0
  FileUtils.mkdir_p(INSTALL_DIR)
  FileUtils.cp_r('src/.', INSTALL_DIR, verbose: true)
  FileUtils.ln_s(File.join(INSTALL_DIR, MAIN), File.join(INSTALL_DIR, EXEC), force: true)
  FileUtils.chmod('+x', File.join(INSTALL_DIR, MAIN))
  FileUtils.ln_s(File.join(INSTALL_DIR, EXEC), '/usr/local/bin/', force: true)
end

task :gem do |t|

  FileUtils.mkdir_p('out')

  Dir.mktmpdir("lapack-gem-") do |tmp|

    FileUtils.mkdir_p(File.join(tmp, 'lib'))
    FileUtils.cp_r('src/.', File.join(tmp, 'lib'))
    FileUtils.cp('build/lapack.gemspec', tmp)
    FileUtils.mkdir_p(File.join(tmp, 'bin'))

    Dir.chdir(tmp) do |d|

      FileUtils.ln_s('../lib/lapack.rb', 'bin/lapack')
      FileUtils.chmod('+x', 'lib/lapack.rb')

      `gem build lapack.gemspec`
    end

    FileUtils.cp(Dir["#{tmp}/*.gem"], 'out')
  end
end
