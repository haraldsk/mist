require 'mist/provisioner'
require 'mist/status'
require 'log4r'
require 'json'
require 'ruby-progressbar'
require 'terminal-table'
require 'base64'


module
  Mist
  class Interface

    include YAML

    def initialize
      @instances = YAML.load( File.read( Mist::Config::INSTANCE_FILE ) )

      unless @instances
        puts "Could not open #{Dir.pwd}/#{Mist::Config::INSTANCE_FILE}"
      end

      @mock    = ENV['MOCK']
      @dns     = Mist::Provisioner::DNS.new( )
      @compute = Mist::Provisioner::Compute.new( { :mock => @mock } )
      @status  = Mist::Status.new()

    end

    def create

      servers = []
      @instances.each_key do |key|
      net_labels = @instances[key]['nets'].keys
      net_ids = net_labels.map { |label| @compute.network_by_label(label).id }

      # grab a ssh key
      ssh_key_file = File.new( Mist::Config::SSH_PUB_FILE, File::RDONLY )
      ssh_key_enc = Base64.encode64(ssh_key_file.read.to_s)

      s =  @compute.create(
        :name        => key,
        :flavor      => @instances[key]['flavor'],
        :image       => @instances[key]['image'],
        :disk_config => @instances[key]['disk_config'],
        :personality => [ {
          :path     => '/root/.ssh/authorized_keys',
          :contents => ssh_key_enc,
        } ],
        :networks    => net_ids,
        :block       => false
      )

      status = {}
      status[key] = {
        :server => {
          :uuid        =>  s.id,
          :flavor      => @instances[key]['flavor'],
          :image       => @instances[key]['image'],
          :disk_config => @instances[key]['disk_config'],
          :networks    => net_ids,
        },
        :dns => {
          :domain => @instances[key]['domain'],
        }
      }

      @status.update(status)
      servers << s
    end

    total = 0
    bar = ProgressBar.create(
      :format => '%a |%b>>%i| %p%% %t',
      :total => servers.length * 100,
      :title => 'Server creation')

    while total < servers.length * 100
      total = 0
      servers.each do |s|
        s.reload
        total += s.progress
      end
      bar.progress = total
      sleep 10
    end


    # create dns
    dns_bar = ProgressBar.create(
      :format => '%a |%b>>%i| %p%% %t',
      :total => servers.length,
      :title => 'DNS setup      ')

      servers.each do |s|
        dns = []
        s.wait_for { ready? }
        status = @status.get_by_name(s.name)


        # iterate over configured networks on server
        s.addresses.each_pair do |k,v|
          v.each do |ipv|
            ip = ipv['addr']
            version = ipv['version']
            domain = @instances[s.name]['nets'][k]
            type = ''
            if version == 4
              type = 'A'
            elsif version == 6
              type = 'AAAA'
            end

            zone_id,rec_id = @dns.create_record(s.name, domain, type, ip)

            dns << {
              :domain   => domain,
              :network  => k,
              :ip       => ip,
              :type     => type,
              :zone_id  => zone_id,
              :rec_id   => rec_id,
              :record   => "#{s.name}.#{domain} #{type} #{ip}"
            }
          end
        end

        status[:dns] = dns
        @status.update_by_name(s.name, status)
        dns_bar.increment
      end
    end

    def destroy
      @instances.each_key do |key|
        @compute.destroy_by_name(key)
        @instances[key]['nets'].each_value do |domain|
          @dns.destroy_record_by_name( key, domain )
        end
        status = {}
        status[key] = {}
        @status.update(status)
      end
    end

    def reboot
      @instances.each_key do |key|
        @compute.destroy(key)
      end
    end

    def flavors
        rows = []
        @compute.flavors.each do |flavor|
          rows << [ flavor.id, flavor.name ]
        end

        table = Terminal::Table.new ({
          :title    => "Instance flavors",
          :headings => ['Id', 'Name'],
          :rows     => rows
        })
        return table

    end

    def images
        rows = []
        @compute.images.each do |image|
          rows << [ image.id, image.name ]

        end

        table = Terminal::Table.new ({
          :title    => "Server images",
          :headings => ['Id', 'Name'],
          :rows     => rows
        })
        return table
    end

    def servers
      rows = []
      @compute.servers.each do |server|
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
        flavor = @compute.flavor_by_id(server.flavor_id)
        image = @compute.image_by_id(server.image_id)
        rows << [ server.name, server.ipv4_address, privaddr, "#{netname}: #{addr} ", "#{server.progress}%", server.disk_config , flavor.name, image.name, server.id ]

      end

      table = Terminal::Table.new ({
        :title    => "Running servers",
        :headings => ['Name', 'External IPv4', 'Internal IPv4', 'Custom Net: IPv4', 'Progess', 'Disk Config', 'Flavour', 'Image', 'UUID'],
        :rows     => rows
      })
      return table
    end

    def networks
      rows = []
      @compute.networks.each do |network|
        rows << [ network.label, network.cidr, network.id ]
      end

      table = Terminal::Table.new ({
        :title    => "Networks",
        :headings => [ 'Label', 'CIDR', 'Id' ],
        :rows     => rows
      })
      return table
    end
  end

  def destroy

  end

end
