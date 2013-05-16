require 'spec_helper'

module Cleric
  describe RepoManager do
    subject(:manager) { RepoManager.new(repo_agent, announcer) }
    let(:repo_agent) { mock('RepoAgent').as_null_object }
    let(:announcer) { mock('Announcer').as_null_object }

    describe '#initialize' do
      it 'takes a repo agent and an announcer' do
        RepoManager.new(repo_agent, announcer)
      end
    end

    describe '#create' do
      let(:chatroom) { 'my_room' }

      after(:each) { manager.create('my_org/my_repo', 123, chatroom: chatroom) }

      it 'tells the configured repo agent to create the repo' do
        repo_agent.should_receive(:create_repo).with('my_org/my_repo')
      end
      it 'announces the successful repo creation' do
        announcer.should_receive(:successful_action).with('Repo "my_org/my_repo" created')
      end
      it 'tells the agent to add the repo to the team' do
        repo_agent.should_receive(:add_repo_to_team).with('my_org/my_repo', 123)
      end
      it 'announces the successful addition of the repo to the team' do
        announcer.should_receive(:successful_action)
          .with('Repo "my_org/my_repo" added to team "123"')
      end
      context 'when passed a chatroom' do
        it 'tells the agent to add chatroom notification to the repo' do
          repo_agent.should_receive(:add_chatroom_to_repo).with('my_org/my_repo', 'my_room')
        end
        it 'announces the successful addition of the chatroom to the repo' do
          announcer.should_receive(:successful_action)
            .with('Repo "my_org/my_repo" notifications will be sent to chatroom "my_room"')
        end
      end
      context 'when passed a nil chatroom' do
        let(:chatroom) { nil }

        it 'does not tell the agent to add chatroom notification to the repo' do
          repo_agent.should_not_receive(:add_chatroom_to_repo)
        end
        it 'does not announces the successful addition of the chatroom to the repo' do
          announcer.should_not_receive(:successful_action)
            .with(/\ARepo "my_org\/my_repo" notifications will be sent to chatroom/)
        end
      end
    end
  end
end
