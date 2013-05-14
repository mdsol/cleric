require 'thor'

module Cleric
  class Repo < Thor
    desc 'create <name>', 'Create the repo <name> and assign a team'
    option :team, required: true, type: :numeric, desc: 'The team\'s numerical id'
    def create(name)
      announcer = ConsoleAnnouncer.new($stdout)
      config = CLIConfigurationProvider.new
      github_agent = GitHubAgent.new(config)
      manager = RepoManager.new(github_agent, announcer)
      manager.create(name, options[:team])
    end
  end

  class CLI < Thor
    desc 'repo [COMMAND] ...', 'Manage repos'
    subcommand 'repo', Repo
  end
end
