require 'fileutils'

module LaPack
  ##
  # Base package provider. I.e. database wrapper.
  # Should know how to:
  # * fetch packages index and manage
  # * show package info
  # * download, make & install packages
  # * remove packages
  # * keeps multiple versions
  class Provider

    ##
    # Initialization with LaENV instance
    def initialize(env, name, params)
      @name = name

      # Check if db dir exists
      @dbdir = File.join(env.dbs_store, name)
      if File.exists?(@dbdir)
        raise "Can't write to #{@dbdir}. Not a directory" unless File.directory?(@dbdir)
      else
        FileUtils.mkdir_p(@dbdir)
      end
      configure(params)
      init(@dbdir)
    end

    ##
    # Configuration
    #
    # Accepts any parameters (+params+) for configuration as Hash
    def configure(params = {})
      true
    end

    ##
    # Initialization
    #
    # Uses +dbdir+ argument for filesystem initialization
    # No index update required there.
    #
    def init(dbdir)

    end

    ##
    # Updates package index
    #
    def update
      true
    end

    ##
    # Shows available packages
    #
    def list
      return []
    end

    def install(*packages)
      puts "Dummy implementation. Should install: #{packages.join(",")}"
    end

    def show(package)
      []
    end
  end
end
