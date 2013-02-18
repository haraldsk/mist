require 'thor'
require 'log4r'
require 'mist/command'

module Mist
  class Cli < Thor

      desc "up", "create and start servers"
      subcommand "up", Command::Up
      desc "destroy", "destroy and remove servers"
      subcommand "destroy", Command::Destroy
      desc "info", "information on servers and services"
      subcommand "info", Command::Info
  end
end
