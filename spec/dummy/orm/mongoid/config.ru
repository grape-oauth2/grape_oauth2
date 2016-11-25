$:.unshift(File.dirname(__FILE__))

require 'app/twitter'

run Twitter::API
