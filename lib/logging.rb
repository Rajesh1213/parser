#! /usr/bin/env ruby
module Logging
    class << self
        def log(message, timestamp=true)
            msg = "#{timestamp ? "[#{Time.now.strftime("%T")}] " : nil}#{message}"
            puts "\e[32m#{msg}\e[0m"
        end

        def error(message, timestamp= true)
            error = "#{timestamp ? "[#{Time.now.strftime("%T")}] " : nil}#{message}"
            puts "\e[31m#{error}\e[0m"
        end
    end
end
