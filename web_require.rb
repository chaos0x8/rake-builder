#!/usr/bin/ruby

def web_require url
    resultFile = "#{File.dirname(__FILE__)}/#{File.basename(url)}"
    system "wget #{url}" unless File.exist? resultFile
    require_relative resultFile
end

