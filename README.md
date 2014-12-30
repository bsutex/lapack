lapack
======

Simple packaging tool for **_LaTeX_**

## Motivation
  Sometimes we need *.sty files just in place. So lapack is tool for managing versioned local *.sty files.

## Installation
Current installation process is to copy source files to /opt directory and create link to lapack.rb @ `/usr/local/bin.`

Running `sudo rake install` will do the job.

## Usage

* `lapack add %reponame%` - adds repo to your repos list
* `lapack list %reponame%` - lists all packages  in repo. No filters yet. `grep` is your friend :)
* `lapack install %reponame% %packagename%... [%dirname%]` - install packages with `packagename` from repo with `reponame` to directory `%dirname%` (if specifyed). Directory must be created
* `lapack remove %reponame% %packagename%...` - remove package from cache
* `lapack dbs` - list currently plugged dbs

## Roadmap
  * git recipes support
  * verions
  * dist-upgrade-like actions

## Dependencies
  Currently for Ruby you need
  * colorize
