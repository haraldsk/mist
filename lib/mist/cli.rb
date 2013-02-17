require 'thor'
require 'log4r'
require 'mist/command'

module Mist
  class Cli < Mist::Command::Base

      desc "up", "create and start servers"
      subcommand "up", Command::Up
      desc "destroy", "destroy and remove servers"
      subcommand "destroy", Command::Destroy
  end
end
