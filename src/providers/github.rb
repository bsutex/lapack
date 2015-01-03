module LaPack

  class GithubProvider < Provider

    ## Entries per github query page
    @@PER_PAGE = 100

    def initialize(env, params = {})
      super env, 'github', params

      @github_db = "https://api.github.com/search/repositories?q=language:tex&page=%d&per_page=#{@@PER_PAGE}"
    end

    def init(dbdir)
      # dbdir path
      @dbdir = dbdir
      # dbdir name
      @packages = File.join(dbdir, 'pkg')
      # Package index
      @index = File.join(dbdir, "#{@name}.json")

      FileUtils.mkdir_p(@packages) unless File.exists?(@packages)

      raise "Can't write to #{@packages}. Not a directory" unless File.directory?(@packages)
    end

    def update
      first_page = JSON.parse(LaPack.gets(@github_db % [ 1 ]), symbolize_names: true)
      repos_count = first_page[:total_count]
      pages = (repos_count / @@PER_PAGE) + ((repos_count % @@PER_PAGE) == 0 ? 0 : 1)
      repos = []

      repos << scan_page(first_page)
      repos << (2..pages).map do |page|
        sleep(60 / 5) # Five requests per minute limitation
        LaPack.log("Getting page #{page} from #{pages}")
        scan_page(JSON.parse(LaPack.gets(@github_db % [page]), symbolize_names: true))
      end

      File.open(@index, "w") {|f| f << repos.to_json}
    end

    def scan_page(page)
      page[:items].map{|item| item.select{|k, v| [:html_url, :name, :description, :git_url, :full_name].include?(k)}}
    end

    def list
      log("Unavailable", :warning)
    end

    def show(package)
      log("Unavailable", :warning)
    end

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
