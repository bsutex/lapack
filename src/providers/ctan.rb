module LaPack

  class CtanProvider < Provider

    def initialize(env, params = {})
      super env, 'ctan', params

      ## Here is where package index stored
      @package_list = 'http://ctan.org/json/packages'
      ## Here you can find info about package
      @package_info = 'http://ctan.org/json/pkg/%s'
    end

    def init(dbdir)
      # dbdir path
      @dbdir = dbdir
      # dbdir name
      @packages = File.join(dbdir, 'pkg')
      # Package index
      @index = File.join(dbdir, "#{@name}.json")
      # Ctan archive fetch
      @ctan_fetch = 'http://mirrors.ctan.org%s'

      FileUtils.mkdir_p(@packages) unless File.exists?(@packages)

      raise "Can't write to #{@packages}. Not a directory" unless File.directory?(@packages)
    end

    def update
      LaPack.get(@package_list, @index)
    end

    def list
      raise "Update db first" unless File.exists?(@index)
      File.open(@index, "r") {|f| JSON.parse(f.read, symbolize_names: true)}
    end

    def show(package)
      JSON.parse(LaPack.gets(@package_info % package), symbolize_names: true)
    end

    def install(to_dir, *packages)
      packages.each do |package|
        LaPack.log("Installing #{package.blue.bold}")
        if list.select{|p| p[:name].eql?(package)}.empty?
          raise ("No such package #{package}")
        else
          install_package(package, to_dir)
        end
      end
    end

    private
    def install_package(package, to_dir)

      package_dir = File.join(@packages, package)

      FileUtils.mkdir_p(package_dir)

      stys = []
      Dir.mktmpdir("lapack-#{package}-") do |tmp|
        package_info = show(package)
        if package_info.has_key?(:ctan)
          stys = ctan_install(package_info, tmp)
        elsif package_info.has_key?(:install)
          LaPack.log("Build from :install")
        elsif package_info.has_key?(:texlive)
          LaPack.log("Build from :texlive")
        else
          raise("Don't know how to build #{package}")
        end


        stys.each{|sty| FileUtils.cp(sty, package_dir)}
      end

      Dir["#{package_dir}/*.sty"].each do |sty|
        FileUtils.ln_s(sty, to_dir, force: true)
      end
    end

    def ctan_install(package_info, tmpdir)
      link = (@ctan_fetch % package_info[:ctan][:path]) + ".zip"
      arch = File.join(tmpdir, "#{package_info[:name]}.zip")
      LaPack.get(link, arch)
      `unzip #{arch} -d #{File.join(tmpdir, "src")}`
      Dir["#{tmpdir}/**/*.ins"].each do |ins|
        Dir.chdir(File.dirname(ins)) do |dir|
          LaPack.log("LaTex on #{ins}")
          system "latex #{ins}"
        end
      end

      Dir["#{tmpdir}/**/*.sty"]
    end
  end
end