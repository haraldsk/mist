module Mist
  class Status
    attr_reader :status

    def initialize
      file = File.new( Mist::Config::INSTATUS_FILE,
                      File::RDONLY|File::CREAT, 0644)

      file.flock(File::LOCK_EX)

      if file.size > 0
        content = file.read.to_s
        @status = ::JSON::parse(content)
      else 
        @status = {}
      end

      file.flock(File::LOCK_UN)
    end

    def get_by_name(name)
      return @status[name]
    end

    # Updates entire hash
    def update (s)

      file = File.new( Mist::Config::INSTATUS_FILE,
                      File::WRONLY|File::TRUNC, 0644)

      file.flock(File::LOCK_EX)
      @status.merge!(s)
      file.write(::JSON.pretty_generate( @status ) )
      file.flock(File::LOCK_UN)
      file.close
    end

    def update_by_name(name, s)
      status = {}
      status[name] = s;
      update(status)
    end

    private

    def read
      file = File.new( Mist::Config::INSTATUS_FILE,
                      File::RO|File::CREAT, 0644)

      file.flock(File::LOCK_EX)

      if file.size > 0
        content = file.read.to_s
        @status = ::JSON::parse(content)
      else 
        @status = {}
      end

      file.flock(File::LOCK_UN)
    end
  end
end
