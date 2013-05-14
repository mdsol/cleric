require 'spec_helper'

module Cleric
  describe RepoManager do
    subject(:manager) { RepoManager.new(repo_agent) }
    let(:repo_agent) { mock('RepoAgent').as_null_object }
    let(:name) { 'example/repo_name' }

    after(:each) { manager.create(name, 123) }

    describe '#create' do
      it 'tells the configured repo agent to create the repo' do
        repo_agent.should_receive(:create_repo).with(name)
      end
      it 'tells the agent to add the repo to the team' do
        repo_agent.should_receive(:add_repo_to_team).with(name, 123)
      end
    end
  end
end
