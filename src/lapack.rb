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

puts ENV['LAPACK']


require "#{ENV['LAPACK']}/laconf"
require "#{ENV['LAPACK']}/providers/provider"
require "#{ENV['LAPACK']}/providers/ctan"



module LaPack
  LENV.dbs_init

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

  ##
  # List available packages for +dbs+
  #
  def LaPack.list(*dbs)
    if dbs.length == 1 && dbs.first.eql?("all")
      # TODO:
      log("`all` unsupported yet", :warning)
    else

      dbs.each do |dbname|
        LENV.db(dbname).list.each do |entry|
          printf("%#{-60}s %s\n", "#{dbname.magenta}/#{entry[:name].magenta.bold}", "#{entry[:caption].blue.bold}")
        end
        puts
        puts
      end

    end

  end

  ##
  # Add db by name if supported
  #
  #
  def LaPack.add_db(name, args = {})
    LENV.add(name.to_s, args) unless !LENV.supports?(name)
  end

  def LaPack.log(string, level = :info)
    puts LOG_LEVELS[level] % string
  end

  def LaPack.add(db, args={})
    add_db(db, args={})
  end

  def LaPack.install(db, *packages)
    LENV.db(db).install(*packages)
  end

  def LaPack.update(*dbnames)
    dbnames.each do |dbname|
      LENV.db(dbname).update
    end

  end
end

if (ARGV.empty?)
  puts "No args passed"
else
  LaPack.send(ARGV[0], *ARGV[1..ARGV.length])
end


