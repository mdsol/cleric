require 'thor'

module Cleric
  module CLIDefaults
    def config
      @config ||= CLIConfigurationProvider.new
    end
    def github
      @github ||= GitHubAgent.new(config)
    end
  end

  class Repo < Thor
    include CLIDefaults

    desc 'create <name>', 'Create the repo <name> and assign a team'
    option :team, required: true, type: :numeric, desc: 'The team\'s numerical id'
    def create(name)
      console = ConsoleAnnouncer.new($stdout)
      hipchat = HipChatAnnouncer.new(config, console)
      manager = RepoManager.new(github, hipchat)
      manager.create(name, options[:team])
    end
  end

  class CLI < Thor
    include CLIDefaults

    desc 'auth', 'Create auth tokens to avoid repeated password entry'
    def auth
      github.create_authorization
    end

    desc 'repo [COMMAND] ...', 'Manage repos'
    subcommand 'repo', Repo
  end
end
