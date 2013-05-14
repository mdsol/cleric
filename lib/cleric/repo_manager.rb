module Cleric
  class RepoManager
    def initialize(repo_agent, announcer)
      @repo_agent = repo_agent
      @announcer = announcer
    end

    # Creates a repo.
    # @param name [String] Name of the repo, e.g. "my_org/my_repo".
    # @param team [String] Numerical id of the team.
    def create(name, team)
      @repo_agent.create_repo(name)
      @announcer.successful_action("Repo \"#{name}\" created")
      @repo_agent.add_repo_to_team(name, team)
      @announcer.successful_action("Repo \"#{name}\" added to team \"#{team}\"")
    end
  end
end
