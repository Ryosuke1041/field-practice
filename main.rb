# coding: utf-8

require 'dxruby'

filename = Window.openFilename([["スクリプト(*.rb)", "*.rb"]], "実行するスクリプト選択")

if filename
    begin
        load filename
    rescue => e
        print "<#{e.class}>"
        print "#{e.message.chomp('utf-8')}\n\n"
        e.backtrace.each { |msg| puts "・#{msg}" }
        puts "------  please enter  ------"
        gets
    end
end
