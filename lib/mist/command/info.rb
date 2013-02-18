require 'mist/interface'

module Mist
  module Command
    class Info < Base

      desc "servers", "show information on servers"
      def servers
        Mist::Interface.new.servers
      end

      desc "images", "show information on images"
      def images
        Mist::Interface.new.images
      end

      desc "flavors", "show information on flavors"
      def flavors
        Mist::Interface.new.flavors
      end
    end
  end
end
