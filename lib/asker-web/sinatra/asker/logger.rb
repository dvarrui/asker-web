# frozen_string_literal: true

#require_relative 'application'
#require_relative 'project'

#module Logger
#  def self.verbose(msg)
#    puts msg if Application.instance.config['global']['verbose'] == 'yes'
#    Project.instance.get(:logfile)&.write("#{msg}\n")
#  end

#  def self.verboseln(msg)
#    verbose(msg + "\n")
#  end
#end
