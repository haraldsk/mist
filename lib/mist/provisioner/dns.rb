require 'mist/provisioner/base'

module Mist
  module Provisioner
    class DNS < Base

      def initialize( params = { } )
        super
        @dns = Fog::DNS.new( @providers['dns'] )
      end

      def show_zones
        @dns.zones.all.each { |zone| puts "ZoneId: #{zone.id}:  #{zone.domain}" }
      end

      def show_records
        @dns.zones.all.each do |zone|
          zone.records.all.each do |r|
            puts "ZoneId: #{zone.id}, RecordId: #{r.id} #{r.name} #{r.type} #{r.value}"
          end
        end
        # zone = @dns.zones.get('3611869')
        # zone.records.all.each { |r| puts r.attributes[:name] }
      end
      def create_record(name, domain, type, value)

        @dns.zones.all.each do |zone|
          if domain == zone.domain
            r = zone.records.create(
              :value   => value,
              :name => "#{name}.#{domain}",
              :type => type,
            )
            puts "Created ZoneId: #{zone.id}, RecordId: #{r.id} #{r.name} #{r.type} #{r.value}"
          end
        end
      end

      def destroy_record(name, domain)
        @dns.zones.all.each do |zone|
          if domain == zone.domain
            zone.records.all.each do |r|
              if "#{name}.#{domain}" == r.name
                puts "Purging #{r.id} #{r.name} #{r.type} #{r.value}"
                r.destroy
              end
            end
          end
        end

      end
    end
  end
end
