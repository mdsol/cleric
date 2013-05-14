require 'spec_helper'

module Cleric
  describe RepoManager do
    subject(:manager) { RepoManager.new(repo_agent) }
    let(:repo_agent) { mock('RepoAgent') }
    let(:name) { 'example/repo_name' }

    describe '#create' do
      it 'tells the configured repo agent to create the repo' do
        repo_agent.should_receive(:create_repo).with(name)
        manager.create(name)
      end
    end
  end
end
