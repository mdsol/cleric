module Cleric
  class GitHubAgent
    def initialize(config)
      @config = config
    end

    # Adds chatroom notifications to a repo.
    # @param repo [String] Name of the repo, e.g. "my_org/my_repo".
    # @param chatroom [String] Name or id of the chatroom.
    def add_chatroom_to_repo(repo, chatroom)
      client.create_hook(
        repo, 'hipchat', auth_token: @config.hipchat_repo_api_token, room: chatroom
      )
    end

    # Adds a GitHub repo to a team.
    # @param repo [String] Name of the repo, e.g. "my_org/my_repo".
    # @param team [String] Numeric id of the team.
    def add_repo_to_team(repo, team)
      client.add_team_repository(team.to_i, repo)
    end

    # Adds a GitHub user to a team.
    # @param username [String] Username of the user to add.
    # @param team [String] Numeric id of the team.
    def add_user_to_team(username, team, listener)
      client.add_team_member(team.to_i, username)
      listener.successful_action("User \"#{username}\" added to team \"#{team}\"")
    end

    # Creates a GitHub authorization and saves it to the config.
    def create_authorization
      auth = client.create_authorization(scopes: %w(repo), note: 'Cleric')
      @config.github_credentials = { login: credentials[:login], oauth_token: auth.token }
    end

    # Creates a GitHub repo.
    # @param name [String] Name of the repo, e.g. "my_org/my_repo".
    def create_repo(name)
      org_name, repo_name = name.split('/')
      client.create_repository(repo_name, organization: org_name, private: 'true')
    end

    # Verifies that the user's public email matches that given. On failure,
    # calls the `verify_user_public_email` method on the listener.
    # @param username [String] The user's username.
    # @param email [String] The asserted email for the user.
    # @param listener [Object] The target of any callbacks.
    def verify_user_public_email(username, email, listener)
      user = client.user(username)
      listener.verify_user_public_email_failure unless user.email == email
    end

    private

    def client
      @client ||= create_client
    end

    def create_client
      client = Octokit::Client.new(credentials)
    end

    def credentials
      @credentials ||= @config.github_credentials
    end
  end
end
