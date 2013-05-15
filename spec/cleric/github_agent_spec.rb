require 'spec_helper'

module Cleric
  describe GitHubAgent do
    subject(:agent) { GitHubAgent.new(config) }
    let(:config) { mock('ConfigProvider', github_credentials: credentials).as_null_object }
    let(:credentials) { { login: 'me', password: 'secret' } }
    let(:client) { mock('GitHubClient').as_null_object }

    before(:each) { Octokit::Client.stub(:new) { client } }

    shared_examples :client do
      it 'creates a GitHub client with the configured credentials' do
        Octokit::Client.should_receive(:new).with(credentials)
      end
    end

    describe '#add_chatroom_to_repo' do
      before(:each) { config.stub(:hipchat_repo_api_token) { 'REPO_API_TOKEN' } }
      after(:each) { agent.add_chatroom_to_repo('my_org/my_repo', 'my_room') }

      include_examples :client
      it 'adds the chatroom to the repo via the client' do
        client.should_receive(:create_hook)
          .with('my_org/my_repo', 'hipchat', room: 'my_room', auth_token: 'REPO_API_TOKEN')
      end
    end

    describe '#add_repo_to_team' do
      after(:each) { agent.add_repo_to_team('my_org/my_repo', '1234') }

      include_examples :client
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

    describe '#create_authorization' do
      before(:each) do
        client.stub(:create_authorization) do
          stub('Auth', token: 'abc123')
        end
      end
      after(:each) { agent.create_authorization }

      include_examples :client
      it 'creates an authorization via the client' do
        client.should_receive(:create_authorization)
          .with(hash_including(scopes: %w(repo), note: 'Cleric'))
      end
      it 'saves it to the config' do
        config.should_receive(:github_credentials=)
          .with(hash_including(login: 'me', oauth_token: 'abc123'))
      end
    end

    describe '#create_repo' do
      after(:each) { agent.create_repo('my-org/my-repo') }

      include_examples :client
      it 'creates a private repo via the client' do
        client.should_receive(:create_repository)
          .with('my-repo', hash_including(organization: 'my-org', private: 'true'))
      end
    end
  end
end

