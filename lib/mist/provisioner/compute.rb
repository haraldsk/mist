require 'mist/provisioner/base'
require 'terminal-table'

module Mist
  module Provisioner
    class Compute < Base

      def initialize(params = {})
        super
        @compute = Fog::Compute.new( @providers['compute'] )
      end

      def flavor_by_id(id)
        return @compute.flavors.get(id)
      end
      def flavors
        return @compute.flavors.all
      end

      def image_by_id(id)
        return @compute.images.get(id)
      end

      def images
        return @compute.images.all
      end

      # for debug
      def get_servers
        s = []
        @compute.servers.all.each do |server|
          if [ 'rack10', 'rack11' ].include? server.name
            s << server
          end

        end

          return s
      end

      def servers
        return @compute.servers.all
      end

      def networks
        return @compute.networks.all
      end

      def network_by_label(label)
        @compute.networks.all.each do |net|
          if net.label == label
            return net
          end
        end
      end

      def create(params = {})
        params = {
          :personality  => [],
          :networks     => [],
          :metadata     => {},
          :disk_config => 'AUTO',
        }.merge(params)

        server = nil

        unless ENV['MOCK']
          server = @compute.servers.create(
            :name        => params[:name],
            :flavor_id   => params[:flavor],
            :image_id    => params[:image],
            :disk_config => params[:disk_config],
            :networks    => params[:networks],
            :personality => params[:personality]
            # :metadata    => params[:metadata]
          )
        else
          server = @compute.servers.create(
            :name => params[:name],
            :flavor_id => compute.flavors.first.id,
            :image_id => compute.images.first.id
          )
        end

        if params[:block]
          server.wait_for { ready? }
        end
        return server
      end

      def destroy_by_name(name)
        @compute.servers.all.each do |server|
          server.destroy if name == server.name
        end

      end

      def destroy_by_id(uuid)
        @compute.servers.get(id).destroy
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


      def reboot_by_id(uuid, hard=true)
        if hard
          @compute.servers.get(id).reboot HARD
        else
          @compute.servers.get(id).reboot
        end
      end

    end
  end
end
