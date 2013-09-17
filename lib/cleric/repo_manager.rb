module Cleric

  # Provides services for managing repos. Coordinates activities between
  # different service agents.
  class RepoManager
    def initialize(repo_agent, listener)
      @repo_agent = repo_agent
      @listener = listener
    end

    def create(name, team, options)
      @repo_agent.create_repo(name, @listener)

      add_team(name, team)
      optionally_add_chatroom(name, options)
    end

    def update(name, options)
      optionally_add_team(name, options)
      optionally_add_chatroom(name, options)
    end

    private

    def add_chatroom(repo_name, chatroom)
      @repo_agent.add_chatroom_to_repo(repo_name, chatroom, @listener)
    end

    def add_team(repo_name, team)
      @repo_agent.add_repo_to_team(repo_name, team, @listener)
    end

    def optionally_add_chatroom(repo_name, options)
      add_chatroom(repo_name, options[:chatroom]) if options[:chatroom]
    end

    def optionally_add_team(repo_name, options)
      add_team(repo_name, options[:team].to_i) if options[:team]
    end
  end
end
