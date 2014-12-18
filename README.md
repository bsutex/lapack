lapack
======

Simple packaging tool for latex

## Dependencies
  Currently for Ruby you need
  * colorize 

## Installation
Current installation process is to copy source files to /opt directory and create link to lapack.rb @ `/usr/local/bin.`

Running `sudo rake install` will do the job.

## Usage
(mostly not implemented blueprints for now)
* `lapack add %reponame%` - adds repo to your repos list
* `lapack list %reponame%` - lists all packages  in repo. No filters yet. `grep` is your friend :)
* `lapack install [options] %reponame% %packagename%` - install package with `packagename` from repo with `reponame`
  This action creates `dist`-folder for package at your repos folder.
* `lapack bundle package... dirname` creates links for `.sty` files at specifyed directory
