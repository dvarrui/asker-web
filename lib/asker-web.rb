#!/usr/bin/ruby

require_relative 'asker-web/sinatra/sinatra_front_end'
require_relative 'application'

module AskerWeb
  def self.show_help
    puts "Usage:"
  end

  def self.up
    #SinatraFrontEnd.run!
  end

  def self.show_version
    puts "#{Application::NAME} (version #{Application::VERSION})"
  end
end
