module Cleric
  class GitHubAgent
    def initialize(config)
      @config = config
    end

    # Creates a GitHub repo.
    # @param name [String] Name of the repo, e.g. "my_org/my_repo".
    def create_repo(name)
      credentials = @config.github_credentials
      client = Octokit::Client.new(credentials)
      org_name, repo_name = name.split('/')
      client.create_repository(repo_name, organization: org_name, private: 'true')
    end
  end
end
