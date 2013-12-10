require 'spec_helper'

module Cleric
  describe CLIConfigurationProvider do
    subject(:config) { CLIConfigurationProvider.new(filename) }
    let(:filename) { 'tmp/clericrc' }
    let(:saved_config) do
      [
        'hipchat:',
        '  api_token: API_TOKEN',
        '  announcement_room_id: ROOM_ID',
        '  repo_api_token: REPO_API_TOKEN'
      ].join("\n")
    end

    before(:each) do
      Dir.mkdir('tmp') unless Dir.exists?('tmp')
      File.open(filename, 'w') { |file| file.puts(saved_config) }
    end
    after(:each) do
      File.delete(filename)
    end

    describe '#github_credentials' do
      before(:each) do
        # Stubbing credential input as if the load fails and `readline` is
        # *not* stubbed then the test run will stall waiting for input!
        $stdin.stub(:readline).and_return("me\n", "secret\n")
      end

      context 'when no credentials are saved' do
        it 'prompts for username and password' do
          config.github_credentials.should == { login: 'me', password: 'secret' }
        end
      end
      context 'when credentials are save' do
        let(:saved_config) { "github:\n  login: ME\n  oauth_token: ABC123" }

        it 'loads the credentials from the user config file' do
          config.github_credentials.should == { login: 'ME', oauth_token: 'ABC123' }
        end
      end
    end

    describe '#github_credentials=' do
      it 'saves the credentials to the config file' do
        config.github_credentials = { login: 'me', oauth_token: 'abc123' }
        file = YAML::load(File.open(filename))
        file['github']['login'].should == 'me'
        file['github']['oauth_token'].should == 'abc123'
      end
    end

    describe '#hipchat_announcement_room_id' do
      it 'loads the room id from the user config file' do
        config.hipchat_announcement_room_id.should == 'ROOM_ID'
      end
    end

    describe '#hipchat_api_token' do
      it 'loads the token from the user config file' do
        config.hipchat_api_token.should == 'API_TOKEN'
      end
    end

    describe '#hipchat_repo_api_token' do
      it 'loads the token from the user config file' do
        config.hipchat_repo_api_token.should == 'REPO_API_TOKEN'
      end
    end

    describe '#repo_agent' do
      # Ensure `new` returns differing instances.
      before(:each) { GitHubAgent.stub(:new).and_return(double('Agent'), double('Agent')) }

      it 'creates a configured GitHub agent' do
        GitHubAgent.should_receive(:new).with(config)
        config.repo_agent
      end
      it 'returns the same object instance each time' do
        config.repo_agent.should be(config.repo_agent)
      end
    end
  end
end
