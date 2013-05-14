module Cleric
  class RepoManager
    def initialize(repo_agent)
      @repo_agent = repo_agent
    end

    # Creates a repo.
    # @param name [String] Name of the repo, e.g. "my_org/my_repo".
    def create(name)
      @repo_agent.create_repo(name)
    end
  end
end
