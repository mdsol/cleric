module Cleric
  class GitHubAgent
    def initialize(config)
      @config = config
    end

    # Adds a GitHub repo to a team.
    # @param repo [String] Name of the repo, e.g. "my_org/my_repo".
    # @param team [String] Numeric id of the team.
    def add_repo_to_team(repo, team)
      client.add_team_repository(team.to_i, repo)
    end

    # Creates a GitHub repo.
    # @param name [String] Name of the repo, e.g. "my_org/my_repo".
    def create_repo(name)
      org_name, repo_name = name.split('/')
      client.create_repository(repo_name, organization: org_name, private: 'true')
    end

    private

    def client
      @client ||= create_client
    end

    def create_client
      credentials = @config.github_credentials
      client = Octokit::Client.new(credentials)
    end
  end
end
