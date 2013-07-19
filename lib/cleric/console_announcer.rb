module Cleric
  class ConsoleAnnouncer
    include ANSI::Code

    def initialize(io)
      @io = io
    end

    def chatroom_added_to_repo(repo, chatroom)
      write_success(%Q[Repo "#{repo}" notifications will be sent to chatroom "#{chatroom}"])
    end

    def commits_without_pull_requests(repo, commits)
      write_failure(%Q[Repo "#{repo}" has the following commits not covered by pull requests:\n] +
        commits.join("\n"))
    end

    def repo_added_to_team(repo, team)
      write_success(%Q[Repo "#{repo}" added to team "#{team}"])
    end

    def repo_audit_passed(repo)
      write_success(%Q[Repo "#{repo}" passed audit])
    end

    def repo_created(repo)
      write_success(%Q[Repo "#{repo}" created])
    end

    def repo_fetching_latest_changes
      write_action("Fetching latest changes for local repo")
    end

    def repo_obsolete_pull_request(base, head)
      write_warning(%Q[Commits #{base}..#{head} in pull request are no longer present in the repo])
    end

    def user_added_to_team(username, team)
      write_success(%Q[User "#{username}" added to team "#{team}"])
    end

    def user_removed_from_org(username, email, org)
      write_success(%Q[User "#{username}" (#{email}) removed from organization "#{org}"])
    end

    private

    def write_action(message)
      @io.puts(message)
    end

    def write_failure(message)
      @io.puts(red { message })
    end

    def write_success(message)
      @io.puts(green { message })
    end

    def write_warning(message)
      @io.puts(yellow { message })
    end
  end
end
