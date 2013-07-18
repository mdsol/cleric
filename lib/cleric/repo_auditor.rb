require 'set'

module Cleric

  # Provides services for auditing repositories. Coordinates activities between
  # local repositories and different service agents, e.g. GitHub.
  class RepoAuditor
    def initialize(config, listener)
      @config = config
      @listener = listener
    end

    # Identifies commits present in the named repo that do not have
    # corresponding pull requests. Assumes a working directory is currently a
    # local copy of the repo.
    def audit_repo(name)
      git = Git.open('.')

      @listener.repo_fetching_latest_changes
      git.fetch

      ranges = repo_agent.repo_pull_request_ranges(name)

      commits_with_pr = ranges.inject(Set.new) do |set, range|
        set.merge(
          git.log(nil).between(range[:base], range[:head]).map {|commit| commit.sha }
        )
      end

      # Passing `nil` to `log` to ensure all commits are returned.
      commits_without_pr = git.log(nil)
        .select {|commit| commit.parents.size == 1 && !commits_with_pr.include?(commit.sha) }
        .map {|commit| commit.sha }

      if commits_without_pr.empty?
        @listener.repo_audit_passed(name)
      else
        @listener.commits_without_pull_requests(name, commits_without_pr)
      end
    end

    private

    def repo_agent
      @repo_agent ||= @config.repo_agent
    end
  end
end
