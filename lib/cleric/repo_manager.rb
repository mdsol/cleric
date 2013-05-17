module Cleric

  # Provides services for managing repos. Coordinates activities between
  # different service agents.
  class RepoManager
    def initialize(repo_agent, listener)
      @repo_agent = repo_agent
      @listener = listener
    end

    # Creates a repo.
    # @param name [String] Name of the repo, e.g. "my_org/my_repo".
    # @param team [String] Numerical id of the team.
    # @param options [Hash] Options, e.g. `{ chatroom: 'my_room' }`
    def create(name, team, options)
      @repo_agent.create_repo(name, @listener)
      @repo_agent.add_repo_to_team(name, team, @listener)

      if chatroom = options[:chatroom]
        @repo_agent.add_chatroom_to_repo(name, chatroom, @listener)
      end
    end
  end
end
