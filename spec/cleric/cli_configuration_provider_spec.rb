require 'spec_helper'

module Cleric
  describe CLIConfigurationProvider do
    before(:all) do
      Dir.mkdir('tmp') unless Dir.exists?('tmp')
      File.open('tmp/clericrc', 'w') do |file|
        file.puts('hipchat:')
        file.puts('  api_token: API_TOKEN')
        file.puts('  announcement_room_id: ROOM_ID')
      end
    end
    after(:all) do
      File.delete('tmp/clericrc')
    end

    subject(:config) { CLIConfigurationProvider.new('tmp/clericrc') }

    describe '#github_credentials' do
      it 'prompts for username and password' do
        $stdin.stub(:readline).and_return("me\n", "secret\n")
        config.github_credentials.should == { login: 'me', password: 'secret' }
      end
    end

    describe '#github_credentials=' do
      it 'saves the credentials to the config file' do
        config.github_credentials = { login: 'me', oauth_token: 'abc123' }
        file = YAML::load(File.open('tmp/clericrc'))
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
  end
end
