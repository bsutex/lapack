#!/usr/bin/env ruby

# Provides download uri functionality
require 'open-uri'
# Utils for linking, copying, removing files
require 'fileutils'

# Color output to console
# TODO: If not installed replace with fake mixin.
require 'colorize'

# JSON parsing and generation
require 'json'

# Provides methods for working with temp dirs
require 'tmpdir'

ENV['LAPACK'] = File.dirname(File.realpath(__FILE__))

DEBUG = true

require "#{ENV['LAPACK']}/laenv"
require "#{ENV['LAPACK']}/providers/provider"
require "#{ENV['LAPACK']}/providers/ctan"
require "#{ENV['LAPACK']}/providers/github"



module LaPack
  # Init dbs structure
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
      # TODO: More sofisticated pretty pring
      # TODO: assuming we had json like structure
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
  def LaPack.add_db(name, args = {})
    LENV.add(name.to_s, args) unless !LENV.supports?(name)
  end

  ##
  # Logging method
  # TODO: Remove from LaPack module. Move to utils.rb
  def LaPack.log(string, level = :info)
    puts LOG_LEVELS[level] % string unless LENV.quiet? # Do not print anything if quiet
  end

  ##
  # Add db to local repo. Creates needed structure @ ~/.config/lapack/db
  #
  def LaPack.add(db, args={})
    add_db(db, args={})
  end

  ##
  # Install packages.
  # If last argument from packages list is directory
  #   install all packages to directory
  # else
  #   install to current working dir
  #
  def LaPack.install(db, *packages)
    raise "Empty package list" unless !packages.last.nil? # No packages specified at all

    if File.directory?(packages.last)
      to_dir = packages.last
      packages = packages[0..(packages.length - 2)]

      LENV.db(db).install(to_dir, *packages)
    else
      LENV.db(db).install('.', *packages)
    end
  end

  ##
  # Fetch package index for +dbnames+
  #
  def LaPack.update(*dbnames)
    dbnames.each do |dbname|
      LENV.db(dbname).update
    end
  end

  ##
  # Show installed dbs
  #
  def LaPack.dbs
    log("Currently plugged dbs:")
    log(LENV.dbs.map{|d| "\t* %s".white.bold % d}.join("\n"), :plain)
  end

  ##
  # Show package info for +package+ from +db+
  def LaPack.show(db, package)
    puts JSON.pretty_generate(LENV.db(db).show(package))
  end


  ##
  # Remove packages from store
  def LaPack.remove(db, *packages)
    raise "Empty package list" unless !packages.last.nil? # No packages specified at all

    LENV.db(db).remove(*packages)
  end
end

if (ARGV.empty?)
  puts "No args passed"
else
  begin
    LaPack.send(ARGV[0], *ARGV[1..ARGV.length])
  rescue NoMethodError => undefined
    puts "Unknown operation #{undefined.name}"
  rescue Exception => e
    puts e
    puts $!.backtrace if DEBUG
  end
end
