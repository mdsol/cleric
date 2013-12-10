require 'spec_helper'

module Cleric
  describe ConsoleAnnouncer do
    subject(:announcer) { ConsoleAnnouncer.new(io) }
    let(:io) { double('IO') }

    shared_examples 'an announcing method' do |method, opts|
      after(:each) { announcer.__send__(method, *opts[:args]) }

      it 'sends the message to the configured IO object' do
        colorizer = opts[:color] || 'green'
        if colorizer == 'white'
          io.should_receive(:puts).with(opts[:message])
        else
          io.should_receive(:puts).with(ANSI::Code.send(colorizer) { opts[:message] })
        end
      end
    end

    describe '#chatroom_added_to_repo' do
      it_behaves_like 'an announcing method', :chatroom_added_to_repo,
        args: ['a_repo', 'a_chatroom'],
        message: 'Repo "a_repo" notifications will be sent to chatroom "a_chatroom"'
    end

    describe '#commits_without_pull_requests' do
      it_behaves_like 'an announcing method', :commits_without_pull_requests,
        args: ['a_repo', %w(a list of commits)],
        message: "Repo \"a_repo\" has the following commits not covered by pull requests:\n" +
          "a\nlist\nof\ncommits",
        color: 'red'
    end

    describe '#repo_added_to_team' do
      it_behaves_like 'an announcing method', :repo_added_to_team,
        args: ['a_repo', 'a_team'],
        message: 'Repo "a_repo" added to team "a_team"'
    end

    describe '#repo_audit_passed' do
      it_behaves_like 'an announcing method', :repo_audit_passed,
        args: ['a_repo'],
        message: 'Repo "a_repo" passed audit'
    end

    describe '#repo_created' do
      it_behaves_like 'an announcing method', :repo_created,
        args: ['a_repo'],
        message: 'Repo "a_repo" created'
    end

    describe '#repo_fetching_latest_changes' do
      it_behaves_like 'an announcing method', :repo_fetching_latest_changes,
        args: [],
        message: 'Fetching latest changes for local repo',
        color: 'white'
    end

    describe '#repo_obsolete_pull_request' do
      it_behaves_like 'an announcing method', :repo_obsolete_pull_request,
        args: ['123', 'abc', 'def'],
        message: %Q[Commits abc..def in pull request 123 are no longer present in the repo],
        color: 'yellow'
    end

    describe '#user_added_to_team' do
      it_behaves_like 'an announcing method', :user_added_to_team,
        args: ['a_user', 'a_team'],
        message: 'User "a_user" added to team "a_team"'
    end

    describe '#user_not_found' do
      it_behaves_like 'an announcing method', :user_not_found,
        args: ['user@example.com'],
        message: 'User "user@example.com" not found',
        color: 'red'
    end

    describe '#user_removed_from_org' do
      it_behaves_like 'an announcing method', :user_removed_from_org,
        args: ['a_user', 'user@example.com', 'an_org'],
        message: 'User "a_user" (user@example.com) removed from organization "an_org"'
    end
  end
end
