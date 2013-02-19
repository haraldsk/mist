require 'mist/interface'

module Mist
  module Command
    class Info < Base

      desc "servers", "show information on servers"
      def servers
        puts Mist::Interface.new.servers
      end

      desc "images", "show information on images"
      def images
        puts Mist::Interface.new.images
      end

      desc "flavors", "show information on flavors"
      def flavors
        puts Mist::Interface.new.flavors
      end

      desc "networks", "show information on networks"
      def networks
        puts Mist::Interface.new.networks
      end
    end
  end
end
