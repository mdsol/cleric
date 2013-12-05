module Cleric

  # Provides services for managing GitHub using the given configuration.
  # Notifies listeners of activities.
  class GitHubAgent
    def initialize(config)
      @config = config
    end

    # Adds chatroom notifications to a repo.
    # @param repo [String] Name of the repo, e.g. "my_org/my_repo".
    # @param chatroom [String] Name or id of the chatroom.
    def add_chatroom_to_repo(repo, chatroom, listener)
      client.create_hook(
        repo, 'hipchat', auth_token: @config.hipchat_repo_api_token, room: chatroom
      )
      listener.chatroom_added_to_repo(repo, chatroom)
    end

    # Adds a GitHub repo to a team.
    # @param repo [String] Name of the repo, e.g. "my_org/my_repo".
    # @param team [String] Numeric id of the team.
    def add_repo_to_team(repo, team, listener)
      client.add_team_repository(team.to_i, repo)
      listener.repo_added_to_team(repo, team_name(team))
    end

    # Adds a GitHub user to a team.
    # @param username [String] Username of the user to add.
    # @param team [String] Numeric id of the team.
    def add_user_to_team(username, team, listener)
      client.add_team_member(team.to_i, username)
      listener.user_added_to_team(username, team_name(team))
    end

    # Creates a GitHub authorization and saves it to the config.
    def create_authorization
      auth = client.create_authorization(scopes: %w(repo), note: 'Cleric')
      @config.github_credentials = { login: credentials[:login], oauth_token: auth.token }
    end

    # Creates a GitHub repo.
    # @param name [String] Name of the repo, e.g. "my_org/my_repo".
    def create_repo(name, listener)
      org_name, repo_name = name.split('/')
      client.create_repository(repo_name, organization: org_name, private: 'true')
      listener.repo_created(name)
    end

    # Returns an array of hashes with `:base` and `:head` commit SHA hashes for
    # every merged pull request in the named repo.
    def repo_pull_request_ranges(repo)
      client.pull_requests(repo, 'closed')
        .reject {|request| request.merged_at.nil? }
        .map do |request|
          {
            base: request.base.sha,
            head: request.head.sha,
            pr_number: request.number
          }
        end
    end

    # Removes the user from the organization.
    # @param email [String] The email of the user.
    # @param org [String] The name of the organization.
    # @param listener [Object] The target of any callbacks.
    def remove_user_from_org(email, org, listener)
      user = client.search_users(email).first
      if user
        client.remove_organization_member(org, user.username)
        listener.user_removed_from_org(user.username, email, org)
      else
        listener.user_not_found(email)
      end
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

    # Returns the user login (from the GitHub client, rather than from the 
    # stored login)
    def login
      client.user()[:login]
    end

    private

    def client
      @client ||= create_client
    end

    def create_client
      client = Octokit::Client.new(credentials.merge(auto_traversal: true))
    end

    def credentials
      @credentials ||= @config.github_credentials
    end
    
    def team_name(team)
      client.team(team).name
    end
    
  end
end
