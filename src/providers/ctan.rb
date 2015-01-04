module LaPack

  ##
  # Provider for packages from ctan.org
  #
  class CtanProvider < Provider

    ##
    # Create new Ctan instance.
    #
    # No special params expected
    #
    def initialize(env, params = {})
      super env, 'ctan', params

      ## Here is where package index stored
      @package_list = 'http://ctan.org/json/packages'
      ## Here you can find info about package
      @package_info = 'http://ctan.org/json/pkg/%s'
    end

    ##
    # Basic initialization of CtanProvider instance
    #
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

    ##
    # Update package index
    #
    # This will download newer version of package list from ctan.org
    #
    def update
      LaPack.get(@package_list, @index)
    end

    ##
    # List packages from ctan archive
    #
    def list
      raise "Update db first" unless File.exists?(@index)
      File.open(@index, "r") {|f| JSON.parse(f.read, symbolize_names: true)}
    end

    ##
    # Show package details
    #
    def show(package)
      JSON.parse(LaPack.gets(@package_info % package), symbolize_names: true)
    end

    ##
    # Create links for +packages+ at +to_dir+
    #
    # If any package not installed, it will be installed after running this command
    #
    # TODO: Dry run (no linking just installation) will be implemented
    #
    def install(to_dir, *packages)
      packages.each do |package|
        LaPack.log("Installing #{package.blue.bold}")
        if list.select{|p| p[:name].eql?(package)}.empty?
          raise "No such package #{package.white.bold}"
        else
          install_package(package, to_dir)
        end
      end
    end

    ##
    # Remove +packages+ from ctan storage
    #
    def remove(*packages)
      packages.each do |package|
        LaPack.log("Removing #{package.blue.bold}")
        if list.select{|p| p[:name].eql?(package)}.empty?
          raise "No such package #{package.white.bold}"
        else
          ctan_remove(package)
        end
      end
    end

    private
    ##
    # Install package routine
    #
    def install_package(package, to_dir)

      package_dir = File.join(@packages, package)
      FileUtils.mkdir_p(package_dir)
      package_info = show(package)
      # If exists #{package}.json - we already have some version of
      # package. So check version and go ahead.
      package_info_store = File.join(package_dir, "#{package}.json")
      current = {}
      if (File.exists?(package_info_store))
        current = JSON.parse(File.open(package_info_store){|f| f.read}, symbolize_names: true)
      end

      # Current does not exists or is out of date
      # (assuming we always had newer version @ CTAN. Thats little bit wrong)
      if current.empty? || !current[:version][:number].eql?(package_info[:version][:number])

        LaPack.log("Updating #{package}: #{current[:version][:number]} ~> #{package_info[:version][:number]}") unless current.empty?

        # Create tmp dir and do make routine
        Dir.mktmpdir("lapack-#{package}-") do |tmp|
          stys = []
          # Currently we can make from :ctan field. That is mostly common case
          if package_info.has_key?(:ctan)
            stys = ctan_install(package_info, tmp)
          elsif package_info.has_key?(:install)
            LaPack.log("Don't know how to build from install")
          elsif package_info.has_key?(:texlive)
            LaPack.log("Don't know how to build from texlive")
          else
            raise("Don't know how to build #{package}")
          end

          # stys contains path list for all artifacts
          # we'll copy them to package dist dir
          stys.each{|sty| FileUtils.cp(sty, package_dir)}

          # Flush package info to package dist dir
          File.open(package_info_store, "w"){|f| f << package_info.to_json}
        end
      end

      # Relinking stys
      LaPack.log("Linking #{package} content to #{to_dir}")
      Dir["#{package_dir}/*.sty"].each do |sty|
        FileUtils.ln_s(sty, to_dir, force: true)
      end
    end

    def ctan_install(package_info, tmpdir)
      # Place were package archive stored @ CTAN
      link = (@ctan_fetch % package_info[:ctan][:path]) + ".zip"

      arch = File.join(tmpdir, "#{package_info[:name]}.zip")
      # Unpack archive
      LaPack.get(link, arch)
      `unzip #{arch} -d #{File.join(tmpdir, "src")}`
      Dir["#{tmpdir}/**/*.ins"].each do |ins|
        # And do latex on each *.ins file
        Dir.chdir(File.dirname(ins)) do |dir|
          LaPack.log("LaTex on #{ins}")
          system "latex #{ins}"
        end
      end
      # Return list of *.sty
      Dir["#{tmpdir}/**/*.sty"]
    end

    def ctan_remove(package)
       package_dir = File.join(@packages, package)
       FileUtils.rm_r(package_dir)
    end
  end
end
