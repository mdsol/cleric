module Cleric

  # Provides services for managing users. Coordinates activities between
  # different service agents.
  class UserManager
    def initialize(config, listener)
      @config = config
      @listener = listener
    end

    # Remove the user from the organization.
    # @param email [String] The user's email.
    # @param org [String] The name of the organization.
    def remove(username, org)
      repo_agent.remove_user_from_org(username, org, @listener)
    end

    # Callback invoked on failure by the repo agent's #verify_user_public_email
    # method.
    def verify_user_public_email_failure
      throw :verification_failed
    end

    # Verify the named user has the given email and then assigns them to the
    # team.
    # @param username [String] The user's username in the repo system.
    # @param email [String] The user's email.
    # @param team [String] The numeric id of the team in the repo system.
    def welcome(username, email, team)
      # Passing self as listener on verification, so on failure our own
      # #verify_user_public_email_failure method is called, hence the following
      # catch.
      catch :verification_failed do
        repo_agent.verify_user_public_email(username, email, self)
        repo_agent.add_user_to_team(username, team, @listener)
      end
    end

    def repo_agent
      @repo_agent ||= @config.repo_agent
    end
  end
end
