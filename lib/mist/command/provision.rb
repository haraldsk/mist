require 'thor'
require 'mist/interface'

module Mist
  module Command
    class Provision < Base
      default_task(:init)
      desc "init", "initialize mist environement"
      def init

        puts "provision servers"

      end
    end
  end
end
