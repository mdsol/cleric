module Cleric
  class RepoManager
    def initialize(repo_agent)
      @repo_agent = repo_agent
    end

    # Creates a repo.
    # @param name [String] Name of the repo, e.g. "my_org/my_repo".
    # @param team [String] Numerical id of the team.
    def create(name, team)
      @repo_agent.create_repo(name)
      @repo_agent.add_repo_to_team(name, team)
    end
  end
end
