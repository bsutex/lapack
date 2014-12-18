module LaPack
  class LaEnv
    attr_reader(:lastore, :ladb, :lapkg)
    def initialize(args={})
      @quiet = args.delete(:quiet) || false
      @lastore = File.expand_path(args.delete(:lastore)|| "~/.config/lapack")
      @ladb = "db"
      @lapkg = "pkg"

      raise "Unknown args #{args.keys.join(', ')}" unless args.keys.empty?
    end

    def quiet?
      @quiet
    end

    def dbs
      File.join(@lastore, ladb)
    end
  end

  LENV = LaEnv.new
end
