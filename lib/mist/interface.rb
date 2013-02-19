require 'mist/provisioner'
require 'log4r'
require 'json'

module
  Mist
  class Interface

    include YAML

    def initialize
      @instances = YAML.load( File.read( Mist::Config::INSTANCE_FILE ) )

      unless @instances
        puts "Could not open #{Dir.pwd}/#{Mist::Config::INSTANCE_FILE}"
      end

      mock =     ENV['MOCK']
      @dns     = Mist::Provisioner::DNS.new( )
      @compute = Mist::Provisioner::Compute.new( { :mock => mock } )

    end

  def write_instatus (status)

    file = File.new( Mist::Config::INSTATUS_FILE,
                    File::RDWR|File::CREAT, 0644)

    file.flock(File::LOCK_EX)

    if file.size > 0
      content = file.read.to_s
      statusdata = ::JSON::parse(content)

      statusdata.merge!(status)

      file.rewind
      file.truncate 0
    else
      statusdata = status
    end
    file.write(::JSON.pretty_generate( statusdata ) )
    file.flock(File::LOCK_UN)
    file.close
  end
    def create

      @instances.each_key do |key|
        pid = fork do
          ip = @compute.create(
            :name        => key,
            :flavor      => @instances[key]['flavor'],
            :image       => @instances[key]['image'],
            :disk_config => @instances[key]['disk_config'],
            :networks    => @instances[key]['networks'],
            :block       => true
          )
          @dns.create_record(key, @instances[key]['domain'], 'A', ip)

          status = {}
          status[key] = {
            :flavor      => @instances[key]['flavor'],
            :image       => @instances[key]['image'],
            :disk_config => @instances[key]['disk_config'],
            :networks    => @instances[key]['networks'],
            :dns_record  => "#{key}.#{@instances[key]['domain']} A #{ip}"
          }

          write_instatus(status)

        end # fork
      end
    end

    def destroy
      @instances.each_key do |key|
        @compute.destroy(key)
        status = {}
        status[key] = {}
        write_instatus(status)
      end
    end

    def reboot
      @instances.each_key do |key|
        @compute.destroy(key)
      end
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

    def networks
      @compute.networks
    end
  end

  def destroy

  end

end
