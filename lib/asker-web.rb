#!/usr/bin/ruby

require_relative 'asker-web/application'
require_relative 'asker-web/sinatra/web_panel'

module AskerWeb
  def self.show_help
    puts "asker-web"
    puts "Commands:"
    puts "  asker-web up       # Up asker web panel"
    puts "  asker-web help     # Show this help"
    puts "  asker-web version  # Show version"
    exit 0
  end

  def self.up
    WebPanel.run!
    exit 0
  end

  def self.show_version
    puts "#{WebApplication::NAME} (version #{WebApplication::VERSION})"
    exit 0
  end
end
