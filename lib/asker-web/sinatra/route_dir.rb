
# require_relative '../builder/builder'

module Sinatra
  module WebPanel
    module RouteDir

      def self.registered(app)
        app.get '/dir/list' do
          @current=File.join(Dir.pwd)
          load_dir @current
          erb :"dir/list"
        end

        app.get '/dir/list/*' do
          @current=File.join(Dir.pwd, params[:splat] )
          load_dir @current
          erb :"dir/list"
        end

        app.get '/dir/create/*' do
          @current=File.join(Dir.pwd, params[:splat] )
          Builder::create_dir(@current)
          load_dir @current
          erb :"dir/list"
        end
      end

    end
  end
end
