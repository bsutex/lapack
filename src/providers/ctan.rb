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
  end
end