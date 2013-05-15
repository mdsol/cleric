require 'thor'

module Cleric
  class Repo < Thor
    desc 'create <name>', 'Create the repo <name> and assign a team'
    option :team, required: true, type: :numeric, desc: 'The team\'s numerical id'
    def create(name)
      config = CLIConfigurationProvider.new
      console = ConsoleAnnouncer.new($stdout)
      hipchat = HipChatAnnouncer.new(config, console)
      github_agent = GitHubAgent.new(config)
      manager = RepoManager.new(github_agent, hipchat)
      manager.create(name, options[:team])
    end
  end

  class CLI < Thor
    desc 'repo [COMMAND] ...', 'Manage repos'
    subcommand 'repo', Repo
  end
end
