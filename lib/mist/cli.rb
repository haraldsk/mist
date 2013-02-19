require 'thor'
require 'log4r'
require 'mist/command'

module Mist
  class Cli < Mist::Command::Base

      desc "up", "create and start servers"
      subcommand "up", Command::Up
      desc "destroy", "destroy and remove servers"
      subcommand "destroy", Command::Destroy
      desc "info", "information on servers and services"
      subcommand "info", Command::Info
      desc "init", "initialize mist environment"
      subcommand "init", Command::Init
      desc "status", "show locally cached status info"
      subcommand "status", Command::Status
      desc "provision", "provision servers"
      subcommand "provision", Command::Provision
      desc "server", "manage servers from command line"
      subcommand "server", Command::Server
      desc "network", "manage networks from command line"
      subcommand "network", Command::Network
  end
end
