require 'rubygems'
require 'fog'
require 'yaml'

module Mist
  module Provisioner
    class Base
      include YAML

      def initialize (params = {} )

        if  params[:mock]
          Fog.mock!
        end

        @providers = YAML.load( File.read( Mist::Config::PROVIDER_FILE ) )

        unless @providers
          puts "Could not open #{Dir.pwd}/#{Mist::Config::PROVIDER_FILE}"
        end

      end
    end
  end
end
