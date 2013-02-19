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
          rows << [ server.name, server.ipv4_address, privaddr, "#{netname}: #{addr} ", "#{server.progress}%", server.disk_config , flavor.name, image.name, server.id ]

        end

        table = Terminal::Table.new ({
          :title    => "Running servers",
          :headings => ['Name', 'External IPv4', 'Internal IPv4', 'Custom Net: IPv4', 'Progess', 'Disk Config', 'Flavour', 'Image', 'UUID'],
          :rows     => rows
        })
        puts table
      end

      def networks
        rows = []
        @compute.networks.all.each do |network|
          rows << [ network.label, network.cidr, network.id ]

        end

        table = Terminal::Table.new ({
          :title    => "Networks",
          :headings => [ 'Label', 'CIDR', 'Id' ],
          :rows     => rows
        })
        puts table
      end

      def create(params = {})
        params = {
          :networks     => [],
          :metadata     => {},
          :disk_config => 'AUTO',
        }.merge(params)

        # puts params[:networks]

        server = @compute.servers.create(
          :name        => params[:name],
          :flavor_id   => params[:flavor],
          :image_id    => params[:image],
          :disk_config => params[:disk_config],
          :networks    => params[:networks],
          # :metadata    => params[:metadata]
        )

        if params[:block]
          # server.wait_for { ready? }
          while (  server.progress != 100 )
            puts "#{params[:name]} #{server.progress}"
            sleep 20
            server.reload
          end
          return server.ipv4_address
        end
      end

      def destroy_by_name(name)
        @compute.servers.all.each do |server|
          server.destroy if name == server.name
        end

      end

      def destroy_by_uuid(uuid)
        @compute.servers.get(uuid).destroy
      end

      def reboot_by_name(name, hard=true)
        @compute.servers.all.each do |server|
          if hard
            server.reboot HARD if name == server.name
          else
            server.reboot if name == server.name
          end
        end
      end


      def reboot_by_uuid(uuid, hard=true)
        if hard
          @compute.servers.get(uuid).reboot HARD
        else
          @compute.servers.get(uuid).reboot
        end
      end

    end
  end
end
