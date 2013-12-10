require 'spec_helper'

module Cleric
  describe GitHubAgent do
    subject(:agent) { GitHubAgent.new(config) }
    let(:config) { double('ConfigProvider', github_credentials: credentials).as_null_object }
    let(:credentials) { { login: 'me', password: 'secret' } }
    let(:client) { double('GitHubClient').as_null_object }
    let(:listener) { double('Listener').as_null_object }
    
    before(:each) { Octokit::Client.stub(:new) { client } }

    shared_examples :client do
      it 'creates a GitHub client with the configured credentials' do
        Octokit::Client.should_receive(:new).with(credentials.merge(auto_traversal: true))
      end
    end

    it 'uses a single GitHub client across multiple calls' do
      Octokit::Client.should_receive(:new).once
      3.times do
        agent.create_repo('my_org/my_repo', listener)
        agent.add_repo_to_team('my_org/my_repo', '1234', listener)
      end
    end
    
    describe '#login' do
      it 'returns the client login id' do
        client.stub(:user) { {login: 'user'} }
        expect(agent.login).to eq('user')
      end
    end
    
    describe '#add_chatroom_to_repo' do
      before(:each) { config.stub(:hipchat_repo_api_token) { 'REPO_API_TOKEN' } }
      after(:each) { agent.add_chatroom_to_repo('my_org/my_repo', 'my_room', listener) }

      include_examples :client
      it 'adds the chatroom to the repo via the client' do
        client.should_receive(:create_hook)
          .with('my_org/my_repo', 'hipchat', room: 'my_room', auth_token: 'REPO_API_TOKEN')
      end
      it 'announces success to the listener' do
        listener.should_receive(:chatroom_added_to_repo).with('my_org/my_repo', 'my_room')
      end
    end

    describe '#add_repo_to_team' do
      before(:each) { client.stub(:team) { double(name: 'Fabbo Team') } }
      after(:each) { agent.add_repo_to_team('my_org/my_repo', '1234', listener) }

      include_examples :client
      it 'adds the repo to the team via the client' do
        client.should_receive(:add_team_repository).with(1234, 'my_org/my_repo')
      end
      it 'announces success to the listener' do
        listener.should_receive(:repo_added_to_team).with('my_org/my_repo', 'Fabbo Team')
      end
    end

    describe '#add_user_to_team' do
      let(:listener) { double('Listener').as_null_object }
      
      before(:each) { client.stub(:team) { double(name: 'Fabbo Team') } }
      after(:each) { agent.add_user_to_team('a_user', '1234', listener) }

      it 'add the user to the team via the client' do
        client.should_receive(:add_team_member).with(1234, 'a_user')
      end
      it 'announces success to the listener' do
        listener.should_receive(:user_added_to_team).with('a_user', 'Fabbo Team')
      end
    end

    describe '#create_authorization' do
      before(:each) do
        client.stub(:create_authorization) do
          double('Auth', token: 'abc123')
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
      after(:each) { agent.create_repo('my_org/my_repo', listener) }

      include_examples :client
      it 'creates a private repo via the client' do
        client.should_receive(:create_repository)
          .with('my_repo', hash_including(organization: 'my_org', private: 'true'))
      end
      it 'announces success to the listener' do
        listener.should_receive(:repo_created).with('my_org/my_repo')
      end
    end

    describe '#repo_pull_request_ranges' do
      let(:pull_request) do
        double('PullRequest',
          merged_at: merged_at,
          base: double('Commit', sha: '123').as_null_object,
          head: double('Commit', sha: '456').as_null_object,
          number: '789'
        ).as_null_object
      end
      let(:merged_at) { 'some time' }

      before(:each) { client.stub(:pull_requests) { [pull_request] } }

      it 'gets all the closed pull requests' do
        client.should_receive(:pull_requests).with('my_org/my_repo', 'closed')
        agent.repo_pull_request_ranges('my_org/my_repo')
      end
      it 'returns the base and head commit SHA hashes' do
        returned = agent.repo_pull_request_ranges('my_org/my_repo')
        returned.should == [ { base: '123', head: '456', pr_number: '789' } ]
      end

      context 'when encountering a pull request that has not been merged' do
        let(:merged_at) { nil }

        it 'does not return that pull request' do
          returned = agent.repo_pull_request_ranges('my_org/my_repo')
          returned.should be_empty
        end
      end
    end

    describe '#remove_user_from_org' do
      let(:users) { [ double('User', username: 'a_user') ] }

      before(:each) { client.stub(:search_users) { users } }
      after(:each) { agent.remove_user_from_org('user@example.com', 'an_org', listener) }

      it 'finds the user by their public email via the client' do
        client.should_receive(:search_users).with('user@example.com')
      end
      it 'removes the user from the organization via the client' do
        client.should_receive(:remove_organization_member).with('an_org', 'a_user')
      end
      it 'announces success to the listener' do
        listener.should_receive(:user_removed_from_org)
          .with('a_user', 'user@example.com', 'an_org')
      end

      context 'when the user is not found' do
        let(:users) { [] }

        it 'notifies the listener of the failure' do
          listener.should_receive(:user_not_found).with('user@example.com')
        end
        it 'does not notify the listener of success' do
          listener.should_not_receive(:user_removed_from_org)
        end
      end
    end

    describe '#verify_user_public_email' do
      let(:email) { 'user@example.com' }

      before(:each) { client.stub(:user) { double('User', email: email) } }
      after(:each) { agent.verify_user_public_email('a_user', 'user@example.com', listener) }

      include_examples :client
      it 'finds the user via the client' do
        client.should_recieve(:user).with('a_user')
      end

      context 'when the user public email does not match' do
        let(:email) { 'other_user@example.com' }

        it 'calls the failure callback on the listener' do
          listener.should_receive(:verify_user_public_email_failure)
        end
      end

      context 'when the email matches' do
        it 'does not call the failure callback' do
          listener.should_not_receive(:verify_user_public_email_failure)
        end
      end
    end
  end
end

