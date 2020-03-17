
require 'sinatra/base'
require 'coderay'

#require_relative '../../asker/project'
#require_relative '../loader/file_loader'
#require_relative 'formatter/concept_haml_formatter'

require_relative 'helpers'
require_relative 'route_concept'
require_relative 'route_dir'
require_relative 'route_file'

# Used by: command/editor
# SinatraFrontEnd class:
# * get
# * load_dir
# * load_file
class WebPanel < Sinatra::Base
  use Rack::Session::Pool

  set :root,          File.join( File.dirname(__FILE__), "..", ".." )
  set :views,         File.join( File.dirname(__FILE__), "views")
  set :public_folder, File.join( File.dirname(__FILE__), "public")

  helpers  Sinatra::WebPanel::Helpers
  register Sinatra::WebPanel::RouteConcept
  register Sinatra::WebPanel::RouteDir
  register Sinatra::WebPanel::RouteFile

  get '/' do
    redirect '/dir/list'
  end

  def load_dir(dir)
    @filenames = Dir[dir+"/**"].sort!
  end

  def load_file(filename)
    return open(filename) { |i| i.read }
  end

end
