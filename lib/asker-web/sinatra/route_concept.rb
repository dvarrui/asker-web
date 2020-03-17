
require_relative 'asker/loader/file_loader'
require_relative 'formatter/concept_haml_formatter'

module Sinatra
  module WebPanel
    module RouteConcept

      def self.registered(app)
        app.get '/concept/list/*.*' do |path,ext|
          puts path
          puts ext
          @filename = path+"."+ext
          filepath = File.join(Dir.pwd, @filename)
          data = FileLoader.load(filepath)
          @concepts = data[:concepts]
          @lang = @concepts[0].lang
          @context = @concepts[0].context

          session[ 'concepts' ] = @concepts

          @current = File.dirname( filepath )
          erb :"concept/list"
        end

        app.get '/concept/show/:index' do
          @index = params[:index]
          @concepts = session['concepts']
          @concept = @concepts[ @index.to_i ]

          ConceptHAMLFormatter.new(@concept).to_s

          @filename = @concept.filename
          @current  = File.dirname( File.join(Dir.pwd, @filename) )
          erb :"concept/show"
        end
      end

    end
  end
end
