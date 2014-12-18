#!/usr/bin/env ruby
require 'open-uri'
require 'fileutils'
require 'colorize'
require 'json'


def real(path)
  while(File.symlink?(path))
    path = File.readlink(path)
  end
  path
end

ENV['LAPACK'] = File.dirname(File.realpath(__FILE__))

require "#{ENV['LAPACK']}/laconf"

module LaPack

  LOG_LEVELS = {
    warning: "*\t%s".light_red,
    info:  "*\t".yellow.bold + "%s".blue.bold,
    succes: "*\t".green.bold + "%s".green,
    error: "*\t".red.bold + "%s".red.bold,
    plain: "%s"
  }

  ### Получаем файл по url и складываем его по имени файла
  ## url - вообще говоря uri
  ## dst - путь к файлу, в который записываем
  ## laenv - окружение, в котором работаем
  def LaPack.get(url, dst)
    log("Fetching #{url.white.bold} to #{dst.white.bold}")
    File.open(dst, "w"){|f| f << LaPack.gets(url)}
  end

  def LaPack.gets(url)
    open(url).read
  end

  ### Обновить базы по и
  def LaPack.update_db(dbs)
    dbs.each do |db|
      log("Updating #{db[:name].white.bold}") unless LENV.quiet?
      get(db[:source], db[:store])
    end
  end

  def LaPack.list(*dbs)
    if dbs.length == 1 && dbs.first.eql?("all")
      # TODO:
      log("`all` unsupported yet", :warning)
    else
      dbs.each do |dbname|
        installed = Dir["#{File.join(LENV.dbs, dbname, LENV.lapkg)}/**"]
        db_index = []
        File.open(File.join(LENV.dbs, "#{dbname}.db", "#{dbname}.json")) {|f| db_index = JSON.parse(f.read, symbolize_names: true)}
        db_index.each do |entry|
          printf("%#{-60}s %s\n", "#{dbname.magenta}/#{entry[:name].magenta.bold}", "#{entry[:caption].blue.bold}")
        end
      end
    end
  end

  ### Добавить базу данных
  ## Используя
  ## name - имя
  ## index_uri - путь к индексу пакетов.
  ##
  ## TODO: Быбло бы неплохо использовать какую-либо схему для индекса. Сейчас используем структуру CTAN
  def LaPack.add_db(name, index_uri, args = {})
    # Создадим хранилище если еще не создано
    FileUtils.mkdir_p(LENV.dbs) unless File.exists?(LENV.dbs)

    # Файл описывающий базу
    db_file = File.join(LENV.dbs, name)

    # Если такой файл уже есть, то извините
    if(File.exists?(db_file) && !args[:force])
      log("#DB #{name} already exists, use --force flag to overwrite", :error)
    else
      File.open(db_file, "w") do |desc|
        # Пока у нас только имя и путь к индексу. Индекс может быть локальным, никаких проблем.
        desc << {
            name: name,
            source: index_uri,
            store: File.join(LENV.dbs,"#{name}.db", "#{name}.json")
          }.to_json
      end
    end
  end

  def LaPack.log(string, level = :info)
    puts LOG_LEVELS[level] % string
  end

  def LaPack.add(db, index_uri, args={})
    add_db(db, index_uri, args={})
  end

  def LaPack.install(db, package)

  end

  def LaPack.update(*dbnames)
    dbnames.each do |dbname|
      if (dbname.to_s.eql? "all")
        #TODO:
        log("`all` unsupported yet", :warning)
      else
        if (File.exists?(File.join(LENV.dbs, dbname)))
          json = ""
          File.open(File.join(LENV.dbs, dbname), "r") {|f| json = f.read}
          FileUtils.mkdir_p(File.join(LENV.dbs, "#{dbname}.db"))
          update_db([JSON.parse(json, symbolize_names: true)])
        end
      end
    end
  end
end

if (ARGV.empty?)
  puts "No args passed"
else
  LaPack.send(ARGV[0], *ARGV[1..ARGV.length])
end


