$:.unshift(File.dirname(__FILE__))

require 'app/twitter'

use ActiveRecord::ConnectionAdapters::ConnectionManagement

run Twitter::API



