lapack
======

Simple packaging tool for **_LaTeX_**
[![Gem Version](https://badge.fury.io/rb/lapack.svg)](http://badge.fury.io/rb/lapack)

## Motivation
  Sometimes we need *.sty files just in place. So lapack is tool for managing versioned local *.sty files.

## Installation

To build gem run

`rake gem`

Then you can install gem by

`gem install out/lapack-0.0.1.gem`

Or alternativly you can install latest version directly from rubygems.org

`gem install lapack`

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
