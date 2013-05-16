module Cleric
  class RepoManager
    def initialize(repo_agent, announcer)
      @repo_agent = repo_agent
      @announcer = announcer
    end

    # Creates a repo.
    # @param name [String] Name of the repo, e.g. "my_org/my_repo".
    # @param team [String] Numerical id of the team.
    # @param options [Hash] Options, e.g. `{ chatroom: 'my_room' }`
    def create(name, team, options)
      @repo_agent.create_repo(name)
      @announcer.successful_action("Repo \"#{name}\" created")
      @repo_agent.add_repo_to_team(name, team)
      @announcer.successful_action("Repo \"#{name}\" added to team \"#{team}\"")

      if chatroom = options[:chatroom]
        @repo_agent.add_chatroom_to_repo(name, chatroom)
        @announcer.successful_action("Repo \"#{name}\" notifications will be sent to chatroom \"#{chatroom}\"")
      end
    end
  end
end
