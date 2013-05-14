require 'spec_helper'

module Cleric
  describe GitHubAgent do
    subject(:agent) { GitHubAgent.new(config) }
    let(:config) { mock('ConfigProvider', github_credentials: credentials) }
    let(:credentials) { { login: 'me', password: 'secret' } }
    let(:client) { mock('GitHubClient').as_null_object }

    before(:each) { Octokit::Client.stub(:new) { client } }

    shared_examples :client do
      it 'creates a GitHub client with the configured credentials' do
        Octokit::Client.should_receive(:new).with(credentials)
      end
    end

    describe '#create_repo' do
      include_examples :client

      after(:each) { agent.create_repo('my-org/my-repo') }

      it 'creates a private repo via the client' do
        client.should_receive(:create_repository)
          .with('my-repo', hash_including(organization: 'my-org', private: 'true'))
      end
    end

    describe '#add_repo_to_team' do
      include_examples :client

      after(:each) { agent.add_repo_to_team('my_org/my_repo', '1234') }

      it 'adds the repo to the team via the client' do
        client.should_receive(:add_team_repository).with(1234, 'my_org/my_repo')
      end
    end

    it 'uses a single GitHub client across multiple calls' do
      Octokit::Client.should_receive(:new).once
      3.times do
        agent.create_repo('my_org/my_repo')
        agent.add_repo_to_team('my_org/my_repo', '1234')
      end
    end
  end
end

