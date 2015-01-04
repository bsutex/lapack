module LaPack
  ##
  # Enviroment class for lapack.
  # Defines runtime options
  #
  class LaEnv

    attr_reader(:lastore, :ladb, :lapkg)

    def initialize(args={})
      @quiet = args.delete(:quiet) || false
      @lastore = File.expand_path(args.delete(:lastore)|| "~/.config/lapack")
      @ladb = "db"
      @lapkg = "pkg"
      FileUtils.mkdir_p(dbs_store)

      raise "Unknown args #{args.keys.join(', ')}" unless args.keys.empty?
    end

    def quiet?
      @quiet
    end

    ##
    # Returns dbs path
    #
    def dbs_store
      File.join(@lastore, ladb)
    end

    def db(name)
      @dbs_hash[name.to_sym]
    end

    def dbs
      @dbs_hash.keys
    end

    def add(db, params = {})
      if(db.to_sym.eql?(:ctan))
        File.open(File.join(dbs_store, "#{db}.db"), "w") {|f| f << {name: 'ctan', clazz: 'CtanProvider', params: {}}.to_json}
      else
        raise "Unsupported"
      end
    end

    def supports?(dbtype)
      (:ctan.eql? dbtype.to_sym)
    end

    def dbs_init
      @dbs_hash = Dir["#{dbs_store}/*.db"]
      .map do |dbfile|
        File.open(dbfile){|f| JSON.parse(f.read, symbolize_names: true)}
      end
      .inject({}) do |h, db|
        h.update({
          db[:name].to_sym => LaPack::const_get(db[:clazz]).new(self, db[:params])
        })
      end
    end
  end

  LENV = LaEnv.new
end
