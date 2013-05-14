require 'spec_helper'

module Cleric
  describe GitHubAgent do
    subject(:agent) { GitHubAgent.new(config) }
    let(:config) { mock('ConfigProvider', github_credentials: credentials) }
    let(:credentials) { { login: 'me', password: 'secret' } }
    let(:client) { mock('GitHubClient').as_null_object }

    before(:each) { Octokit::Client.stub(:new) { client } }
    after(:each) { agent.create_repo('my-org/my-repo') }

    describe '#create_repo' do
      it 'creates a GitHub client with the configured credentials' do
        Octokit::Client.should_receive(:new).with(credentials)
      end
      it 'creates a private repo via the client' do
        client.should_receive(:create_repository)
          .with('my-repo', hash_including(organization: 'my-org', private: 'true'))
      end
    end
  end
end

