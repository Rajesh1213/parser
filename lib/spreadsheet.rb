#! /usr/bin/env ruby

require 'spreadsheet'

module SpreadSheet
    class << self
        def newbook
            Spreadsheet::Workbook.new
        end
        
        def create_worksheet(book)
            sheet = book.create_worksheet(name: 'Sheet1')
            sheet.row(0).concat %w{"URL" "Param1" "Param2" "Param3" "Param4" "Param5" "param6"}
            sheet
        end
    end
end
