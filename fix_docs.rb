#!/usr/bin/env ruby
# Script to fix YARD documentation by making the API overview the main page

require 'fileutils'

docs_dir = 'docs'
index_file = File.join(docs_dir, 'index.html')
api_overview_file = File.join(docs_dir, '_index.html')

if File.exist?(api_overview_file)
  puts "Copying API overview to main index page..."
  FileUtils.cp(api_overview_file, index_file)
  puts "✅ Documentation fixed: API overview is now the main page"
else
  puts "❌ Error: API overview file not found at #{api_overview_file}"
  exit 1
end 