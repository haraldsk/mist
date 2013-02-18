require 'mist/provisioner/base'
require 'terminal-table'

module Mist
  module Provisioner
    class Compute < Base

      def initialize(params = {})
        super
        @compute = Fog::Compute.new( @providers['compute'] )
      end

      def flavors
        rows = []
        @compute.flavors.all.each do |flavor|
          rows << [ flavor.id, flavor.name ]
        end

        table = Terminal::Table.new ({
          :title    => "Instance flavors",
          :headings => ['Id', 'Name'],
          :rows     => rows
        })
        puts table

      end

      def images
        rows = []
        @compute.images.all.each do |image|
          rows << [ image.id, image.name ]

        end

        table = Terminal::Table.new ({
          :title    => "Server images",
          :headings => ['Id', 'Name'],
          :rows     => rows
        })
        puts table
      end

      def servers
        rows = []
        @compute.servers.all.each do |server|
          netname, addr, privaddr = nil
          server.addresses.each_pair do |k,v|
            next if k == 'public'
            if k == 'private'
              privaddr = v[0]['addr']
              next
            end
            netname = k
            addr = v[0]['addr']
          end
          flavor = @compute.flavors.get(server.flavor_id)
          image = @compute.images.get(server.image_id)
          rows << [ server.name, server.ipv4_address, privaddr, "#{netname}: #{addr} ", flavor.name, image.name, server.id ]

        end

        table = Terminal::Table.new ({
          :title    => "Running servers",
          :headings => ['Name', 'External IPv4', 'Internal IPv4', 'Custom Net: IPv4', 'Flavour', 'Image', 'UUID'],
          :rows     => rows
        })
        puts table
      end

    end
  end
end
