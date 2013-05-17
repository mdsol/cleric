module Cleric
  class ConsoleAnnouncer
    include ANSI::Code

    def initialize(io)
      @io = io
    end

    def chatroom_added_to_repo(repo, chatroom)
      write_success("Repo \"#{repo}\" notifications will be sent to chatroom \"#{chatroom}\"")
    end

    def repo_added_to_team(repo, team)
      write_success("Repo \"#{repo}\" added to team \"#{team}\"")
    end

    def repo_created(repo)
      write_success("Repo \"#{repo}\" created")
    end

    def user_added_to_team(username, team)
      write_success("User \"#{username}\" added to team \"#{team}\"")
    end

    def user_removed_from_org(username, email, org)
      write_success("User \"#{username}\" (#{email}) removed from organization \"#{org}\"")
    end

    private

    def write_success(message)
      @io.puts(green { message })
    end
  end
end
