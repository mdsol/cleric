require 'spec_helper'

module Cleric

  describe ConsoleAnnouncer do
    subject(:announcer) { ConsoleAnnouncer.new(io) }
    let(:io) { mock('IO') }

    shared_examples 'an announcing method' do |method, opts|
      after(:each) { announcer.__send__(method, *opts[:args]) }

      it 'sends the message to the configured IO object' do
        io.should_receive(:puts).with(ANSI::Code.green { opts[:message] })
      end
    end

    describe '#chatroom_added_to_repo' do
      it_behaves_like 'an announcing method', :chatroom_added_to_repo,
        args: ['a_repo', 'a_chatroom'],
        message: 'Repo "a_repo" notifications will be sent to chatroom "a_chatroom"'
    end

    describe '#repo_added_to_team' do
      it_behaves_like 'an announcing method', :repo_added_to_team,
        args: ['a_repo', 'a_team'],
        message: 'Repo "a_repo" added to team "a_team"'
    end

    describe '#repo_created' do
      it_behaves_like 'an announcing method', :repo_created,
        args: ['a_repo'],
        message: 'Repo "a_repo" created'
    end

    describe '#user_added_to_team' do
      it_behaves_like 'an announcing method', :user_added_to_team,
        args: ['a_user', 'a_team'],
        message: 'User "a_user" added to team "a_team"'
    end

    describe '#user_removed_from_org' do
      it_behaves_like 'an announcing method', :user_removed_from_org,
        args: ['a_user', 'user@example.com', 'an_org'],
        message: 'User "a_user" (user@example.com) removed from organization "an_org"'
    end
  end
end
