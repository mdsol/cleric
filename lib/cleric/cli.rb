require 'thor'

module Cleric
  module CLIDefaults
    def config
      @config ||= CLIConfigurationProvider.new
    end
    def github
      @github ||= GitHubAgent.new(config)
    end
    def console
      @console ||= ConsoleAnnouncer.new($stdout)
    end
    def hipchat
      @hipchat ||= HipChatAnnouncer.new(config, console)
    end
  end

  class Repo < Thor
    include CLIDefaults

    desc 'create <name>', 'Create the repo <name> and assign a team'
    option :team, type: :numeric, required: true,
      desc: 'The team\'s numerical id'
    option :chatroom, type: :string,
      desc: 'Send repo notifications to the chatroom with this name or id'
    def create(name)
      manager = RepoManager.new(github, hipchat)
      manager.create(name, options[:team], { chatroom: options[:chatroom] })
    end
  end

  class User < Thor
    include CLIDefaults

    desc 'welcome <github-username>', 'Add the existing user to a team and chat'
    option :email, required: true,
      desc: 'The user\'s email address'
    option :team, type: :numeric, required: true,
      desc: 'The team\'s numerical id'
    def welcome(username)
      manager = UserManager.new(config, hipchat)
      manager.welcome(username, options[:email], options[:team])
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

    desc 'user [COMMAND] ...', 'Manage users'
    subcommand 'user', User
  end
end
