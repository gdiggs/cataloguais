#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'bundler'

Bundler.require

get '/' do
  haml :index
end
