require 'spec_helper'

module Cleric
  describe HipChatAnnouncer do
    subject(:announcer) { HipChatAnnouncer.new(config, listener, user) }
    let(:config) { mock('Config', hipchat_api_token: 'api_token', hipchat_announcement_room_id: 'room_id') }
    let(:listener) { mock('Listener').as_null_object }
    let(:hipchat) { mock('HipChat').as_null_object }
    let(:user) {'an_admin'}

    before(:each) { HipChat::API.stub(:new) { hipchat } }

    shared_examples :announcing_method do |method, opts|
      after(:each) { announcer.__send__(method, *opts[:args]) }

      it 'sends the message to upstream listener' do
        listener.should_receive(method).with(*opts[:args])
      end
      it 'creates a HipChat client' do
        HipChat::API.should_receive(:new).with('api_token')
      end
      it 'sends the message to the configured HipChat room' do
        hipchat.should_receive(:rooms_message)
          .with('room_id', 'Cleric', opts[:message], 0, opts[:color] || 'green', 'text')
      end
    end

    describe '#chatroom_added_to_repo' do
      it_behaves_like :announcing_method, :chatroom_added_to_repo,
        args: ['a_repo', 'a_chatroom'],
        message: 'Repo "a_repo" notifications will be sent to chatroom "a_chatroom", set by "an_admin"'
    end

    describe '#repo_added_to_team' do
      it_behaves_like :announcing_method, :repo_added_to_team,
        args: ['a_repo', 'a_team'],
        message: 'Repo "a_repo" added to team "a_team" by "an_admin"'
    end

    describe '#repo_created' do
      it_behaves_like :announcing_method, :repo_created,
        args: ['a_repo'],
        message: 'Repo "a_repo" created by "an_admin"'
    end

    describe '#user_added_to_team' do
      it_behaves_like :announcing_method, :user_added_to_team,
        args: ['a_user', 'a_team'],
        message: 'User "a_user" added to team "a_team" by "an_admin"'
    end

    describe '#user_removed_from_org' do
      it_behaves_like :announcing_method, :user_removed_from_org,
        args: ['a_user', 'user@example.com', 'an_org'],
        message: 'User "a_user" (user@example.com) removed from organization "an_org" by "an_admin"',
        color: 'red'
    end
  end
end
