require 'mist/provisioner'

module
  Mist
  class Interface

    include YAML

    def initialize
      @instances = YAML.load( File.read( Mist::Config::INSTANCE_FILE ) )

      unless @instances
        puts "Could not open #{Dir.pwd}/#{Mist::Config::INSTANCE_FILE}"
      end

      #@dns     = Mist::Provisioner::DNS.new( )
      #@compute = Mist::Provisioner::Compute.new( { :mock => true } )
      @compute = Mist::Provisioner::Compute.new( )

    end

    def create


      # puts @instances

      #      @instances.each_key do |key|
      #        # puts @instances[key]
      #        # @dns.create_record(key, @instances[key]['domain'], 'A', '1.2.3.5')
      #        # @dns.destroy_record(key, @instances[key]['domain'])
      #
      #      end

    end

    def flavors
      @compute.flavors
    end

    def images
      @compute.images
    end

    def servers
      @compute.servers
    end

  end

  def destroy

  end
end
