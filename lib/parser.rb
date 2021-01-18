#! /usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'cgi'
require_relative 'logging'
require_relative 'spreadsheet'

class Parser
    include Logging
    include SpreadSheet
    
    POOL_SIZE = 5 #Default pool size I have taken.
    JOBS = Queue.new
    
    def initialize
        @@book = SpreadSheet.newbook
        @@sheet = SpreadSheet.create_worksheet(@@book)

        @@row = 1;
    end
    
    # Search for anchor tags nodes by css
    def create_jobs(url)
        doc = Nokogiri::HTML(URI.open(url))
        doc.css('a').each do | link |
            JOBS.push link
        end
        Logging.log "Total Jobs #{JOBS.length}"
    end
    
    # THis method will parse the recieved URL link in the arg and call the write a method to write to database ot Spreadsheet.
    def parse_url(link)
        uri = URI.parse(link['href'])
        row = []
        if uri.is_a?(URI::HTTP) && !uri.host.nil?
            unless uri.query.nil?
                params = CGI.parse(uri.query)
                url1 = URI.join(uri.scheme+"://"+uri.host+uri.path)
                row << url1.to_s
                params.keys.map { |param| row << param.to_s }
                
                write_to_spreadsheet(row)
                # Else write to a database. Due to time I am writing it to a file also I thought not to user rails here in this task.
            end
        end
    end
    
    # this will actually write the row to the spreadsheet and then update the row.
    def write_to_spreadsheet(row)
        @@sheet.row(@@row).concat(row)
        @@row = @@row.next
    end

    def initiate_parse
        url = url || "https://medium.com/"
        create_jobs(url)
        
        workers = POOL_SIZE.times.map do
            #Parse each link and save it to the database. or a file
            Thread.new do
                sleep(3) #wanted to see the execution.
                Logging.log "Starting Thread #{Thread.current.object_id.to_s}"
                begin
                    while link = JOBS.pop(true)
                        parse_url(link)
                    end
                rescue ThreadError => e
                    Logging.error(e.inspect)
                end
            end
        end
        
        Logging.log workers
        
        workers.map(&:join)
        
        Logging.log workers
        Logging.log "Total Jobs #{JOBS.length}"
        @@book.write 'parsed_results.xls'
    end
end

p = Parser.new
p.initiate_parse
