$:.unshift(File.dirname(__FILE__))

require 'app/twitter'

use OTR::ActiveRecord::ConnectionManagement

run Twitter::API



