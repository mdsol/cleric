require 'thor'

module Cleric
  class Repo < Thor
    desc "create <name>", "Create the repo <name> and assign a team"
    def create(name)
      config = CLIConfigurationProvider.new
      github_agent = GitHubAgent.new(config)
      RepoManager.new(github_agent).create(name)
    end
  end

  class CLI < Thor
    desc 'repo [COMMAND] ...', 'Manage repos'
    subcommand 'repo', Repo
  end
end
