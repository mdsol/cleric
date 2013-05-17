require 'spec_helper'

module Cleric
  describe RepoManager do
    subject(:manager) { RepoManager.new(repo_agent, listener) }
    let(:repo_agent) { mock('RepoAgent').as_null_object }
    let(:listener) { mock('Listener').as_null_object }

    describe '#create' do
      let(:chatroom) { 'my_room' }

      after(:each) { manager.create('my_org/my_repo', 123, chatroom: chatroom) }

      it 'tells the configured repo agent to create the repo' do
        repo_agent.should_receive(:create_repo).with('my_org/my_repo', listener)
      end
      it 'tells the agent to add the repo to the team' do
        repo_agent.should_receive(:add_repo_to_team).with('my_org/my_repo', 123, listener)
      end
      context 'when passed a chatroom' do
        it 'tells the agent to add chatroom notification to the repo' do
          repo_agent.should_receive(:add_chatroom_to_repo).with('my_org/my_repo', 'my_room', listener)
        end
      end
      context 'when passed a nil chatroom' do
        let(:chatroom) { nil }

        it 'does not tell the agent to add chatroom notification to the repo' do
          repo_agent.should_not_receive(:add_chatroom_to_repo)
        end
      end
    end
  end
end
